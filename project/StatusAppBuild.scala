import sbt._
import sbt.Keys._
import play.Project._
import sbtbuildinfo.Plugin._
import PlayArtifact._
import com.typesafe.sbt.SbtNativePackager._
import com.typesafe.sbt.packager.Keys._

object StatusAppBuild extends Build {

  val awsSdk = "com.amazonaws" % "aws-java-sdk" % "1.4.3"

  val statusAppDependencies = Seq(
    awsSdk,
    "com.typesafe.akka" %% "akka-agent" % "2.1.0",
    cache
  )

  lazy val statusApp = play.Project("status-app", "1.0", statusAppDependencies, path = file("."))
    .settings(buildInfoSettings: _*)
    .settings(playArtifactDistSettings: _*)
    .settings(

    resolvers ++= Seq(Classpaths.typesafeReleases),
    scalacOptions ++= List("-feature"),

    scalaVersion := "2.10.2",

    name in Linux := name.value,
    maintainer := "Philip Wills",
    packageSummary := "Monitors autoscaling groups in an AWS account",
    packageDescription :=
      """Provides a high level overview of the state of autoscaling groups within an AWS account,
        |primarily through introspection of the AWS APIs.
      """.stripMargin,
    linuxPackageMappings in Debian +=
      (packageMapping(
        ((sourceDirectory in Debian).value / "changelog") -> s"/usr/share/${name.value}/sbt/changelog.gz"
      ) withUser "root" withGroup "root" withPerms "0644" gzipped) asDocs(),

    sourceGenerators in Compile <+= buildInfo,
    buildInfoKeys := Seq[BuildInfoKey](
      libraryDependencies in Compile,
      name,
      version,
      BuildInfoKey.constant("buildNumber", Option(System.getenv("BUILD_NUMBER")) getOrElse "DEV"),
      // so this next one is constant to avoid it always recompiling on dev machines.
      // we only really care about build time on teamcity, when a constant based on when
      // it was loaded is just fine
      BuildInfoKey.constant("buildTime", System.currentTimeMillis)
    ),

    magentaPackageName := "ophan-status-app",

    buildInfoPackage := "controllers"
  )
}
