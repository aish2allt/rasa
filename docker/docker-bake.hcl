variable "TARGET_IMAGE_REGISTRY" {
  default = "rasa-pro"
}

variable "TARGET_IMAGE_NAME" {
  default = "${TARGET_IMAGE_REGISTRY}/rasa-pro"
}

variable "BASE_IMAGE_NAME" {
  default = "${TARGET_IMAGE_REGISTRY}/rasa-pro"
}

variable "IMAGE_TAG" {
  default = "localdev"
}

variable "BASE_IMAGE_HASH" {
  default = "localdev"
}

variable "BASE_BUILDER_IMAGE_HASH" {
  default = "localdev"
}

# keep this in sync with the version in .github/poetry_version.txt
# the variable is set automatically for builds in CI
variable "POETRY_VERSION" {
  default = "1.4.2"
}

group "base-images" {
  targets = ["base", "base-poetry"]
}

target "base" {
  dockerfile = "docker/Dockerfile.base"
  tags       = ["${BASE_IMAGE_NAME}:base-${IMAGE_TAG}"]
  cache-to   = ["type=inline"]
}

target "base-poetry" {
  dockerfile = "docker/Dockerfile.base-poetry"
  tags       = ["${BASE_IMAGE_NAME}:base-poetry-${POETRY_VERSION}"]

  args = {
    IMAGE_BASE_NAME = "${BASE_IMAGE_NAME}"
    BASE_IMAGE_HASH = "${BASE_IMAGE_HASH}"
    POETRY_VERSION  = "${POETRY_VERSION}"
  }

  cache-to = ["type=inline"]

  cache-from = [
    "type=registry,ref=${BASE_IMAGE_NAME}:base-poetry-${POETRY_VERSION}",
  ]
}

target "base-builder" {
  dockerfile = "docker/Dockerfile.base-builder"
  tags       = ["${BASE_IMAGE_NAME}:base-builder-${IMAGE_TAG}"]

  args = {
    IMAGE_BASE_NAME = "${BASE_IMAGE_NAME}"
    POETRY_VERSION  = "${POETRY_VERSION}"
  }

  cache-to = ["type=inline"]
}

target "default" {
  dockerfile = "Dockerfile"
  tags       = ["${TARGET_IMAGE_NAME}:${IMAGE_TAG}"]

  args = {
    IMAGE_BASE_NAME         = "${BASE_IMAGE_NAME}"
    BASE_IMAGE_HASH         = "${BASE_IMAGE_HASH}"
    BASE_BUILDER_IMAGE_HASH = "${BASE_BUILDER_IMAGE_HASH}"
  }

  cache-to = ["type=inline"]

  cache-from = [
    "type=registry,ref=${BASE_IMAGE_NAME}:base-${BASE_IMAGE_HASH}",
    "type=registry,ref=${BASE_IMAGE_NAME}:base-builder-${BASE_BUILDER_IMAGE_HASH}",
    "type=registry,ref=${TARGET_IMAGE_NAME}:latest",
  ]
}
