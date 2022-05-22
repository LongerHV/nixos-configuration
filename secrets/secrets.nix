let
  arch = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAuQ0UQO4mMPlQXEPwKharfN0EKBERJpYjq92XAnjqU8";
  nasgul = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII2gRPWw7Ijjn6rNB+2I/97osC6AqarGOsw9jhxzUdAi";
in
{
  "test.age".publicKeys = [ arch nasgul ];
}
