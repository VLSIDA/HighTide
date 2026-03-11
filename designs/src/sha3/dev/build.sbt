ThisBuild / scalaVersion := "2.13.12"
ThisBuild / version      := "0.1.0"

lazy val root = (project in file("."))
  .settings(
    name := "sha3",
    libraryDependencies ++= Seq(
      "edu.berkeley.cs" %% "chisel3" % "3.6.1",
    ),
    scalacOptions ++= Seq(
      "-language:reflectiveCalls",
      "-deprecation",
      "-feature",
      "-Xcheckinit",
    ),
    addCompilerPlugin("edu.berkeley.cs" %% "chisel3-plugin" % "3.6.1" cross CrossVersion.full),
  )
