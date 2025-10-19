open Alcotest

let test_success_case () =
  (* Placeholder test just validates function presence; integration requires server *)
  let _ = Authdog.get_userinfo ~base_url:"https://example.com" ~access_token:"t" in
  (* We cannot actually run Lwt without a server; skip *)
  ()

let () =
  run "authdog" [
    ("client", [ test_case "compiles" `Quick (fun _ -> test_success_case ()) ])
  ]
