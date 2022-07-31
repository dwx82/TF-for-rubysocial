resource "google_storage_bucket" "my_bucket" {
name        = var.bucket_name
location    = var.region
depends_on  = [null_resource.get_credentials]
versioning {
      enabled = true
    }
}


#The function in the triggers block goes through all of the files inside of a given folder
#and checks their checksum. In this way, when a change is detected, the local-exec provisioner
#will be automatically triggered and execute the gsutil command to copy the whole folder into the provided GCS bucket.

resource "null_resource" "upload_folder_content" {

 triggers = {

   file_hashes = jsonencode({

   for fn in fileset(var.folder_path, "**") :

   fn => filesha256("${var.folder_path}/${fn}")

   })

 }

 provisioner "local-exec" {

   command = "gsutil cp -r ${var.folder_path}/* gs://${var.bucket_name}/"

 }
depends_on  = [google_storage_bucket.my_bucket]
}