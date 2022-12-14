let
  nasgul_user = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEYB0EmGsDyitrAiP7nGL+oVYu8noXboTNTGxVemjZ1R1Tb/xnfYusTcM6V1gQgF4aECfTNYBbM9HsIozxMK2hnHDgKkbH3HBvVHzMfGor+p+vtRV+idrpeVQlDocNI3JLA3WGNupv41/RnaQ/vs9EQ3ZvCoFmCaRJ4kxVHwkoaWRiZ0r45vCzI/kq7o4TtdJbVq+J0U9+P/Y8uHl8AatVtNB7uIlaZJmWMlZuMj86YzGqRaMXh0A1vcwY4iPeaI+6fBj01M5m5CoP+a+YzVLgkm2OsUgK5XQ2+ncg+xI/1k6h9v3JzfdkV3JCSUrmwwg3xzq82aC7cPHmHL6pIzSAIPrmjXtHv0hvxLBOsMauPvjycaSIHM/tLZzcQCgPhJ6XvTrA5+MOVgYixlTWw3JBj9UXYscBU0mHaFmduYbXZdgH7jOwDGBi2JFELw89A/g9psSEKPi6dfOBcZEcMwQY8Blp1y4ry2YAFQqEboXS0CPtV4R+t3eOFJAgm6haYOhhjO3GR/ml7SiYj9JeMlh4c/8nBj7ov113+oVdx+N+aj3wMAjLDiYIEvquJMIiTNU/9jp5qFo3SJW4TOijo6fDQN07St/UcTK4d7OmTpU9nK3G1NmvUpI4EDxGPxF/uG05wevSvfqSmccUYIROPuM6KhRcnbCX1PtsYvBJot4KQw==";
  work_user = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvBNDaxfVA4wwWaWnBQfic8opU+dcCQ6olVxqshcdBu0zsfe6ISpRUu6jFf61AFgRDyoUJvHBI73tiC44XovjHoekRAlYeeIlFJiRmg+w5ugYZrRxkn/PzirqFuspAm0a+a+669YibkPoxSs+BsVGp6J4Fe0U/i690qhmoTWoxYv6lc87YxTRWdhPeBQ1WJTUsq82o4wJcVUeZ5ZdzQqrTtwrDL0+gFNGKnMd3oJnslYRq5n4WEzx3JCijdzl9DUmz+0zBzHnQ2cF7wf823LVtSmKjcmkahUhkkFxqSY+y2Y62+2lNp3bXoB+tdjqvJNMNGkQ+NCJVL6YMkNzAhdQMC1VraDyOCqJI+USn9C5ZypmNW98U+oGVu1ftycjAyXZn+CEQgxJ0pWioYnmRIc5cgJeGpwPSaU1CgZ+BCWq/UlLNMKAZDJpovS35wPrvWpUlGlyknLQuqXUdlcR3ybC2b/wZ7YSKflwZ6skbGWceXP0Kdkdm3nENg8TRjBRTuxmPxXaXugmGfNFij1cZ0RuAu9mnhhhfyd0QXxBXgDlU0fvopXOT1Jv79EtrA+siAUsFl+mkSKXsNAlZaovn0h62raWWY2tzT81mt440+Y2DsPy4w011wa29Lt/034Pcu8DSuL1jsyAuac63GLGolaNRS/urE69aW2kwyE5/Hj+OZQ==";
  mordor_user = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCLO8jWFPCx141QQyBBSGFSEY1iGwrcrb0NnNfjDHopx+FDPSo3d8Rat9sMqojL9o80frLxU/SpkC/9BddCu7dqlmPFEt2rNvzG2Evv+Epovr/hHD5EeJP7fNdW+FqoODIK9GOJLstc5h8m7LdMwEpI7FlSVRbhBFhiwwhdbIlGNnFogDggjc9WIux5oyzY6i3O/GNeP/G9Mwi8STGGKS0yuBVtVmsJ+zakrXWpSAhm4N0OSZzxUKGAzLWCs67VnF4VM+/nhCqro9jlpORDyM19AmMtAC/M2NI8T/Um0UaUm/I3wFkOCRqRdbNk6M6pCmTGm6jOszugNjb8zUH4lT1KfSZbo/GIO0Lyxi3bPCQFQLl0r6aVMn0AIOkkNmPg4LvVa7ux9FlaE1qjEoe6TtkZ2i50+4FWWS2ZcFJpiNDQ8crc4TNnrjeOkye4E//gw+6ki3UaTETR7ZwsnnjiTLFw2aJcP8BGOZBVvjmkKSIZ6cLhyo0rc+yamxcWaCup27g8xxLlD6CXDwmvRz04KyxUJf6eBGmX58d3m2zhbDC9pJXh0I5HtbOydTLgY7wDFnLx9p6yNPSLyD4jotKJdCH5IjFL1s41/YzpunkhNRyWvNCLUBS5xiE+4BmFcTFWsov1dwd3+uriR5/Q7iMCnvl2kadAkRcjCcLR3vJKNwfqQ==";
  golum_user = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC29blSuefpfoJoNG11Ub41KgWfKitt0E1NfQnHPPrNOmQzmQDNtU7Qpt296WVhvvl4n8CgNWNT7NR986ndazBMb02LftrFHxa8mRZUd6axFAx47GyTsZHsvwLB8dGBOMp4HjzOvmRg+xo4EK3mDn17EjnsKcoW2/oO2P9sOqLIbf9LdSq5C3198ru8sUNleEQI7kmor4swZonQACEn8Xke+EozU3qZPbEiRKJEvV7OVLLVgon4TU5CnbUvuv3Vs3PEAzfH5jkcIxQPu4eE+BhwNiM0TXqhHaByqJHmFg2zgLQswp5vLwmjSlximrIiD0Fn1iLR9FTx7Oi17N2RJpsZSMDpNL33n7Yw6hH/gESlijabzsHnnphklcFblASg2+2dgyHUQd1v2Hnd20fFR0Qtcl+En1+o7g3y0mpdL4nH6j1lC5OPxz7ToEcLvdOh2t7ovPU7NukbJ269mzua5Ny2o9MeyYo4620whor2Ou88X52E2EhjlfyyhqghrfuiS14r4dpiRcXer2rlY7RCAuea14rnRy1H+gYLu3X0o84M0E0FlB8Vj9kVBOCaeNyo4Z4XajbeAvb6H/xxBWZ22UVIZwpkBtUC4i8/BKXnpyFptzHATNDhFVkWPWcOFCyy3KtgyKXHxKqy37iQS/yNuoxb0FdupV3WN5U9OXqT5xuCdw==";
  users = [ nasgul_user work_user mordor_user golum_user ];

  nasgul = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII2gRPWw7Ijjn6rNB+2I/97osC6AqarGOsw9jhxzUdAi";
  mordor = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGdT6E0OwCh/fF1ji0ExyH+4zhh1znuoT+sCeDgYn9N1";
  golum = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILxTAtlcquAOoCo8PCC6ffrtbcV1uCOxLfck5Rpdir9z";
  systems = [ mordor nasgul golum ];
in
{
  # Tokens
  "extra_access_tokens.age".publicKeys = [ nasgul mordor mordor_user ];

  # Nasgul
  "nasgul_wireguard_priv_key.age".publicKeys = [ nasgul nasgul_user mordor_user ];
  "nasgul_mullvad_priv_key.age".publicKeys = [ nasgul nasgul_user mordor_user ];
  "nasgul_cache_priv_key.pem.age".publicKeys = [ nasgul nasgul_user mordor_user ];
  "nasgul_authelia_jwt_secret.age".publicKeys = [ nasgul nasgul_user mordor_user ];
  "nasgul_authelia_storage_encryption_key.age".publicKeys = [ nasgul nasgul_user mordor_user ];
  "nasgul_authelia_hmac_secret.age".publicKeys = [ nasgul nasgul_user mordor_user ];
  "nasgul_authelia_issuer_private_key.age".publicKeys = [ nasgul nasgul_user mordor_user ];
  "nasgul_authelia_mysql_password.age".publicKeys = [ nasgul nasgul_user mordor_user ];
  "nasgul_authelia_config.age".publicKeys = [ nasgul nasgul_user mordor_user ];
  "nasgul_nextcloud_admin_password.age".publicKeys = [ nasgul nasgul_user mordor_user ];
  "nasgul_authelia_session_secret.age".publicKeys = [ nasgul nasgul_user mordor_user ];
  "nasgul_ldap_password.age".publicKeys = [ nasgul nasgul_user mordor_user ];
  "nasgul_minio_root_credentials.age".publicKeys = [ nasgul nasgul_user mordor_user ];
  "nasgul_sendgrid_token.age".publicKeys = [ nasgul nasgul_user mordor_user ];
  "cloudflare_token.age".publicKeys = [ nasgul nasgul_user mordor_user ];
  "cloudflare_email.age".publicKeys = [ nasgul nasgul_user mordor_user ];

  # Mordor
  "mordor_cache_priv_key.pem.age".publicKeys = [ mordor mordor_user ];

  # Golum
  "golum_wireguard_priv_key.age".publicKeys = [ golum golum_user mordor_user ];
}
