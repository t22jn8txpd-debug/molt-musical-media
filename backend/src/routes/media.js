const express = require("express");
const multer = require("multer");
const { authRequired } = require("../middleware/auth");
const { contentLimiter } = require("../middleware/rateLimit");
const { sanitizeTags } = require("../utils/sanitize");
const {
  uploadBuffer,
  buildSignedUrl,
  buildThumbnailUrl,
  buildWaveformUrl
} = require("../services/cloudinary");

const router = express.Router();

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 50 * 1024 * 1024 }
});

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

      const resourceType = mediaType === "image" ? "image" : "video";
      const tags = parseTags(req.body?.tags);
      const folder = process.env.CLOUDINARY_FOLDER || "molt-media";
      const uploadPreset = process.env.CLOUDINARY_UPLOAD_PRESET || undefined;
      const deliveryType = process.env.CLOUDINARY_DELIVERY_TYPE || "upload";

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
        eager
      });

      const version = result.version;
      const publicId = result.public_id;
      const secureUrl = result.secure_url;
      const signedUrl =
        deliveryType === "authenticated" || deliveryType === "private"
          ? buildSignedUrl({
              publicId,
              resourceType,
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

module.exports = router;
