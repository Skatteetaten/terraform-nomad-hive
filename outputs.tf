output "service_name" {
  description = "Hive service name"
  value       = data.template_file.template_nomad_job_hive.vars.service_name
}

output "buckets" {
  description = "Minio buckets for hive"
  value       = local.buckets
}
