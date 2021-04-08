# Changelog

## [0.4.0]

### Added

- Bump example: minio ~> 0.4.0 #65
- Bump example: postgres ~> 0.4.0 #65
- Bump vagrant-hashistack ~> 0.9.0 #67

### Changed

- Variable names #63
- now uses variable to set consul image [no issue]
- Links and text containing 'fredrikhgrelland' changed to 'skatteetaten' #71

### Fixed

- Docker builds failing - ratelimit #72
- http check to script check #68
- sequence of test ansible [no issue]

## [0.3.1]

### Added

- Add minio-availability health check #57

### Changed

- Increased the [docker pull timeout](https://www.nomadproject.io/docs/drivers/docker#image_pull_timeout) for the hive-image #52
- Changed to anothrNick/github-tag-action to get bumped version tags. Old action is deprecated [no issue]

## [0.3.0]

### Added

- Add intentions section in readme #42
- Update box ~> 0.7.x #45
- Resource allocation variables for proxy #54
- Improve credentials management (vault provided credentials) #44
- Bump example: minio ~> 0.3.0 #51
- Bump example: postgres ~> 0.3.0 #51
- Output variable for port #49

### Changed

- changed paths in `make install` to delete tmp-files in all subdirectories #48

## [0.2.0]

### Added

- Github templates for issues and PRs #29
- Update box ~> 0.6.1 #31
- Automate release process #26
- Added switch for canary deployment #11
- Resource allocation variables #37
- Data example upload #5

### Changed

- Sync origin template #27
- Conditional rendering for docker image #9
- Bump example module: minio ~> 0.2.0 #34
- Bump example module: postgres ~> 0.2.0 #34

## [0.1.0]

### Added

- Healthcheck test #4
- Added documentation #3
- Code to support successful execution of nomad hive job and tests when consul_acl_default_policy is deny #19

### Changed

- Bump vagrant-hashistack version #14
- Sync origin template #16
- Bump mino and postgres version #20

## [0.0.2]

### Fixed

- Support additional env variables #12

## [0.0.1]

### Added

- Switch for nomad job #9
- Initial draft #2
- Changelog #6
