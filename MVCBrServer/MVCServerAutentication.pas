unit MVCServerAutentication;

interface

uses
  System.SysUtils;

type
  TAuthenticationServer = class
  public
    class function Authenticate(const AUser, APassword: string): boolean;
    class function GenerateToken(const AUser: string): string;
    class function ValidateToken(const AToken: string): string;
  end;

implementation

{ TAuthenticationServer }

class function TAuthenticationServer.Authenticate(const AUser,
  APassword: string): boolean;
begin
  result := True;
end;

class function TAuthenticationServer.GenerateToken(const AUser: string): string;
begin
  result := '';
end;

class function TAuthenticationServer.ValidateToken(const AToken: string): string;
begin
  result := '';
end;

end.
