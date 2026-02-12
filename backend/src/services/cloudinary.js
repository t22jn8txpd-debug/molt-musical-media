import cloudinary from "cloudinary";

let configured = false;

function ensureConfigured() {
  if (configured) {
    return;
  }
  if (process.env.CLOUDINARY_URL) {
    cloudinary.config({ secure: true });
    configured = true;
    return;
  }
  const cloudName = process.env.CLOUDINARY_CLOUD_NAME;
  const apiKey = process.env.CLOUDINARY_API_KEY;
  const apiSecret = process.env.CLOUDINARY_API_SECRET;
  if (!cloudName || !apiKey || !apiSecret) {
    throw new Error("cloudinary_not_configured");
  }
  cloudinary.config({
    cloud_name: cloudName,
    api_key: apiKey,
    api_secret: apiSecret,
    secure: true
  });
  configured = true;
}

export const uploadBuffer = async ({
  buffer,
  filename,
  resourceType,
  folder,
  tags,
  uploadPreset,
  deliveryType,
  eager,
  cacheControl
}) => {
  ensureConfigured();
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      {
        resource_type: resourceType,
        public_id: filename,
        folder,
        tags,
        upload_preset: uploadPreset,
        type: deliveryType && deliveryType !== "upload" ? deliveryType : undefined,
        use_filename: true,
        unique_filename: true,
        filename_override: filename,
        cache_control: cacheControl,
        eager
      },
      (error, result) => {
        if (error) {
          return reject(error);
        }
        return resolve(result);
      }
    );
    stream.end(buffer);
  });
};

export const buildSignedUrl = ({ publicId, resourceType, deliveryType, version, transformation }) => {
  ensureConfigured();
  return cloudinary.url(publicId, {
    resource_type: resourceType,
    type: deliveryType,
    sign_url: true,
    secure: true,
    version,
    transformation
  });
};

export const buildThumbnailUrl = ({ publicId, version, width = 600, height = 600 }) => {
  ensureConfigured();
  return cloudinary.url(publicId, {
    resource_type: "image",
    secure: true,
    version,
    transformation: [
      {
        width,
        height,
        crop: "fill",
        gravity: "auto"
      }
    ]
  });
};

export const buildWaveformUrl = ({ publicId, version }) => {
  ensureConfigured();
  return cloudinary.url(publicId, {
    resource_type: "video",
    secure: true,
    version,
    transformation: [
      {
        flags: "waveform",
        color: "white",
        background: "transparent"
      }
    ]
  });
};

export const buildAudioPreviewUrl = ({ publicId, version }) => {
  ensureConfigured();
  return cloudinary.url(publicId, {
    resource_type: "video",
    secure: true,
    version,
    transformation: [
      {
        start_offset: 0,
        duration: 30
      }
    ]
  });
};
