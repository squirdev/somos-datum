module Http.Error exposing (toString)

import Http


toString : Http.Error -> String
toString error =
    case error of
        Http.BadUrl string ->
            string

        Http.Timeout ->
            "http timeout"

        Http.NetworkError ->
            "http network error"

        Http.BadStatus int ->
            String.join ": " [ "http status", String.fromInt int ]

        Http.BadBody string ->
            string
