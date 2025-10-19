open Lwt.Infix

exception Authentication_error of string
exception Api_error of string

let get_userinfo ~base_url ~access_token =
  let base_url =
    let len = String.length base_url in
    if len > 0 && base_url.[len - 1] = '/' then String.sub base_url 0 (len - 1)
    else base_url
  in
  let uri = Uri.of_string (base_url ^ "/v1/userinfo") in
  let headers = Cohttp.Header.of_list [
      ("Content-Type", "application/json");
      ("User-Agent", "authdog-ocaml-sdk/0.1.0");
      ("Authorization", "Bearer " ^ access_token)
    ] in
  Cohttp_lwt_unix.Client.get ~headers uri >>= fun (resp, body) ->
  let status = Cohttp.Response.status resp in
  Cohttp_lwt.Body.to_string body >>= fun body_str ->
  let code = Cohttp.Code.code_of_status status in
  (match code with
   | 401 -> Lwt.fail (Authentication_error "Unauthorized - invalid or expired token")
   | 500 ->
      (try
         let json = Yojson.Safe.from_string body_str in
         let err = Yojson.Safe.Util.(json |> member "error" |> to_string_option) in
         (match err with
          | Some "GraphQL query failed" -> Lwt.fail (Api_error "GraphQL query failed")
          | Some "Failed to fetch user info" -> Lwt.fail (Api_error "Failed to fetch user info")
          | _ -> Lwt.return_unit)
       with _ -> Lwt.return_unit) >>= fun () ->
      if code < 200 || code >= 300 then Lwt.fail (Api_error (Printf.sprintf "HTTP error %d: %s" code body_str)) else Lwt.return body_str
   | _ -> if code < 200 || code >= 300 then Lwt.fail (Api_error (Printf.sprintf "HTTP error %d: %s" code body_str)) else Lwt.return body_str)
