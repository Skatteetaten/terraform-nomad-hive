output "service_name" {
  description = "Hive service name"
  value       = data.template_file.template-nomad-job-hive.vars.service_name
}

output "buckets" {
  value = local.buckets
}
