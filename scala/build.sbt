ThisBuild / version := "0.1.0"

ThisBuild / scalaVersion := "2.13.12"

lazy val root = (project in file("."))
  .settings(
    name := "authdog-scala-sdk",
    organization := "com.authdog",
    description := "Official Scala SDK for Authdog authentication and user management platform",
    
    // Dependencies
    libraryDependencies ++= Seq(
      "com.softwaremill.sttp.client3" %% "core" % "3.9.1",
      "com.softwaremill.sttp.client3" %% "circe" % "3.9.1",
      "io.circe" %% "circe-generic" % "0.14.6",
      "io.circe" %% "circe-parser" % "0.14.6",
      
      // Test dependencies
      "org.scalatest" %% "scalatest" % "3.2.17" % Test,
      "org.mockito" % "mockito-core" % "5.8.0" % Test,
      "org.scalamock" %% "scalamock" % "5.2.0" % Test,
      "org.scalastyle" %% "scalastyle" % "1.0.0" % Test
    ),
    
    // Test configuration
    Test / parallelExecution := false,
    Test / logBuffered := false,
    
    // Scalastyle configuration
    scalastyleConfig := baseDirectory.value / "scalastyle-config.xml",
    
    // Compiler options
    scalacOptions ++= Seq(
      "-deprecation",
      "-feature",
      "-unchecked",
      "-Xlint",
      "-Ywarn-dead-code",
      "-Ywarn-numeric-widen",
      "-Ywarn-value-discard",
      "-Xfatal-warnings"
    ),
    
    // Publishing settings
    publishMavenStyle := true,
    publishTo := {
      val nexus = "https://s01.oss.sonatype.org/"
      if (isSnapshot.value) Some("snapshots" at nexus + "content/repositories/snapshots")
      else Some("releases" at nexus + "service/local/staging/deploy/maven2")
    },
    
    licenses := Seq("MIT" -> url("https://opensource.org/licenses/MIT")),
    homepage := Some(url("https://github.com/authdog/sdk")),
    scmInfo := Some(
      ScmInfo(
        url("https://github.com/authdog/sdk"),
        "scm:git@github.com:authdog/sdk.git"
      )
    ),
    developers := List(
      Developer(
        id = "authdog-team",
        name = "Authdog Team",
        email = "support@authdog.com",
        url = url("https://authdog.com")
      )
    )
  )
