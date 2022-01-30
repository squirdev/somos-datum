package world.somos

import io.circe.generic.extras.Configuration
import io.circe.generic.extras.semiauto.{deriveConfiguredDecoder, deriveConfiguredEncoder}
import io.circe.{Decoder, Encoder}
import world.somos.download.models.{Request, Response}

package object download {

  implicit val circeConfig: Configuration = {
    Configuration.default
  }

  implicit val requestDecoder: Decoder[Request] = {
    deriveConfiguredDecoder[Request]
  }

  implicit val responseEncoder: Encoder[Response] = {
    deriveConfiguredEncoder[Response]
  }

}
