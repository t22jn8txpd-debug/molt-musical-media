import express from "express";
import multer from "multer";
import { authRequired } from "../middleware/auth.js";
import { contentLimiter } from "../middleware/rateLimit.js";
import { sanitizeTags } from "../utils/sanitize.js";
import {
  uploadBuffer,
  buildSignedUrl,
  buildThumbnailUrl,
  buildWaveformUrl,
  buildAudioPreviewUrl
} from "../services/cloudinary.js";

const router = express.Router();

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 50 * 1024 * 1024 }
});

const AUDIO_EXTENSIONS = new Set(["mp3", "wav", "flac", "ogg"]);
const IMAGE_EXTENSIONS = new Set(["jpg", "jpeg", "png", "webp"]);
const AUDIO_MIME_TYPES = new Set([
  "audio/mpeg",
  "audio/mp3",
  "audio/wav",
  "audio/x-wav",
  "audio/flac",
  "audio/ogg"
]);
const IMAGE_MIME_TYPES = new Set(["image/jpeg", "image/png", "image/webp"]);
const MAX_AUDIO_BYTES = 50 * 1024 * 1024;
const MAX_IMAGE_BYTES = 10 * 1024 * 1024;

function parseTags(tags) {
  if (!tags) {
    return [];
  }
  if (Array.isArray(tags)) {
    return sanitizeTags(tags);
  }
  if (typeof tags === "string") {
    try {
      const parsed = JSON.parse(tags);
      if (Array.isArray(parsed)) {
        return sanitizeTags(parsed);
      }
    } catch (err) {
      // treat as comma-separated string
    }
    return sanitizeTags(tags.split(","));
  }
  return [];
}

function inferMediaType(mimetype) {
  if (!mimetype) {
    return null;
  }
  if (mimetype.startsWith("image/")) {
    return "image";
  }
  if (mimetype.startsWith("audio/")) {
    return "audio";
  }
  if (mimetype.startsWith("video/")) {
    return "audio";
  }
  return null;
}

function getExtension(filename) {
  if (!filename) {
    return "";
  }
  const parts = filename.toLowerCase().split(".");
  return parts.length > 1 ? parts.pop() : "";
}

function validateFile({ file, mediaType }) {
  const extension = getExtension(file.originalname);
  if (mediaType === "audio") {
    if (!AUDIO_EXTENSIONS.has(extension) || !AUDIO_MIME_TYPES.has(file.mimetype)) {
      return { ok: false, error: "invalid_audio_type" };
    }
    if (file.size > MAX_AUDIO_BYTES) {
      return { ok: false, error: "audio_too_large" };
    }
  }
  if (mediaType === "image") {
    if (!IMAGE_EXTENSIONS.has(extension) || !IMAGE_MIME_TYPES.has(file.mimetype)) {
      return { ok: false, error: "invalid_image_type" };
    }
    if (file.size > MAX_IMAGE_BYTES) {
      return { ok: false, error: "image_too_large" };
    }
  }
  return { ok: true };
}

async function runVirusScan(file) {
  // Stub for virus scanning integration (e.g., ClamAV or a cloud scanner).
  // Return false to reject the upload.
  return Boolean(file);
}

router.post(
  "/media/upload",
  authRequired,
  contentLimiter,
  upload.single("file"),
  async (req, res, next) => {
    try {
      const file = req.file;
      if (!file) {
        return res.status(400).json({ error: "missing_file" });
      }
      const ok = await runVirusScan(file);
      if (!ok) {
        return res.status(400).json({ error: "virus_scan_failed" });
      }
      const requestedType = req.body?.type;
      const inferredType = inferMediaType(file.mimetype);
      const mediaType =
        requestedType === "image" || requestedType === "audio"
          ? requestedType
          : inferredType;
      if (!mediaType) {
        return res.status(400).json({ error: "unsupported_media_type" });
      }
      const validation = validateFile({ file, mediaType });
      if (!validation.ok) {
        return res.status(400).json({ error: validation.error });
      }
      const resourceType = "auto";
      const tags = parseTags(req.body?.tags);
      const folder = process.env.CLOUDINARY_FOLDER || "molt-media";
      const uploadPreset = process.env.CLOUDINARY_UPLOAD_PRESET || undefined;
      const deliveryType = process.env.CLOUDINARY_DELIVERY_TYPE || "upload";
      const cacheControl = "public, max-age=31536000, immutable";
      const eager =
        mediaType === "image"
          ? [
              {
                width: 600,
                height: 600,
                crop: "fill",
                gravity: "auto"
              }
            ]
          : undefined;
      const result = await uploadBuffer({
        buffer: file.buffer,
        filename: file.originalname,
        resourceType,
        folder,
        tags,
        uploadPreset,
        deliveryType,
        eager,
        cacheControl
      });
      const version = result.version;
      const publicId = result.public_id;
      const secureUrl = result.secure_url;
      const signedUrl =
        deliveryType === "authenticated" || deliveryType === "private"
          ? buildSignedUrl({
              publicId,
              resourceType: result.resource_type,
              deliveryType,
              version
            })
          : null;
      const thumbnailUrl =
        mediaType === "image"
          ? result.eager?.[0]?.secure_url ||
            buildThumbnailUrl({ publicId, version })
          : null;
      const waveformUrl =
        mediaType === "audio" ? buildWaveformUrl({ publicId, version }) : null;
      const previewUrl =
        mediaType === "audio" ? buildAudioPreviewUrl({ publicId, version }) : null;
      const mediaUrl = signedUrl || secureUrl;
      const postId = req.body?.post_id || null;
      const metadata = {
        format: result.format,
        bytes: result.bytes,
        duration: result.duration || null,
        width: result.width || null,
        height: result.height || null,
        resource_type: result.resource_type,
        original_filename: result.original_filename,
        public_id: publicId,
        version,
        thumbnail_url: thumbnailUrl,
        waveform_url: waveformUrl,
        waveform_json: mediaType === "audio" ? { samples: [], source: "pending" } : null,
        preview_url: previewUrl,
        tags
      };
      let mediaRecord = null;
      if (postId) {
        const { data, error } = await req.supabase
          .from("media")
          .insert({
            post_id: postId,
            url: mediaUrl,
            type: mediaType,
            metadata
          })
          .select("id,post_id,url,type,metadata,created_at")
          .single();
        if (error) {
          return res.status(500).json({ error: "db_error", details: error.message });
        }
        mediaRecord = data;
      }
      return res.status(201).json({
        media: mediaRecord,
        upload: {
          url: mediaUrl,
          public_id: publicId,
          type: mediaType,
          metadata
        }
      });
    } catch (err) {
      if (err?.message === "cloudinary_not_configured") {
        return res.status(500).json({ error: "storage_not_configured" });
      }
      return next(err);
    }
  }
);

export default router;
        
