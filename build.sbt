// scala version
scalaVersion := "2.12.8"
// project
organization := "world.somos"
version := "0.1.0"
description := "verify signed message then serve artifact"
// license
licenses += ("Apache-2.0", url("http://www.apache.org/licenses/LICENSE-2.0"))
publishMavenStyle := true

lazy val download = project
  .settings(name := "download")
  .enablePlugins(
    ScalambdaPlugin
  )
  .settings(
    scalambda(
      functionClasspath = "world.somos.download.Main",
      iamRoleSource = RoleFromVariable
    )
  )
  .settings(
    s3BucketName := "somos-download-lambda"
  )
