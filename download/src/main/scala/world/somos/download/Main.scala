package world.somos.download

import cats.effect.IO
import com.amazonaws.services.lambda.runtime.Context
import io.carpe.scalambda.effect.ScalambdaIO
import world.somos.download.models.{Request, Response}

object Main extends ScalambdaIO[Request, Response] {

  // todo: 1) verify signature 2) provide pre-signed s3 url 3) api gateway
  override def run(i: Request, context: Context): IO[Response] = {
    IO {
      Response(
        preSignedS3Url = "todo"
      )
    }
  }

}
