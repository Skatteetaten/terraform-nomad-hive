client {
  host_volume "persistence-minio" {
    path = "/vagrant/persistence/minio"
    read_only = false
  }
}
