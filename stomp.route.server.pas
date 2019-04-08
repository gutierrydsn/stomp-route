unit stomp.route.server;

interface

uses
  System.SysUtils, System.Variants, System.Classes, StompClient, stomp.route.subscribe,
  stomp.route.processor, System.Generics.Collections, System.Rtti;

type
  TSTOMPRouteServer = class
  private
    FHost: String;
    FPort: Integer;
    FVirtualHost: String;
    FClientID: String;
    FUserName: String;
    FPassword: String;
    FAcceptVersion: TStompAcceptProtocol;
    FSTOMPRoute : TSTOMPRouteSubscribe;
    FListProcessor : TList<TStompProcessor>;
    FSTOMPClient: IStompClient;
    mmlistener : IStompListener;

    class var FInstance : TSTOMPRouteServer;

    procedure Subscribe(opStompProcessor : TStompProcessor);
    procedure ReleaseProcessors;
    procedure SetListeners;

    function NewStompClient: IStompClient;
  public

    constructor Create;
    destructor Destroy; override;

    class function GetInstance : TSTOMPRouteServer;
    class procedure SubscribeProcessor(opStompProcessor: TStompProcessor);

    procedure Connect;
    procedure Disconnect;
  published
    property Host: String read FHost write FHost;
    property Port: Integer read FPort write FPort;
    property VirtualHost: String read FVirtualHost write FVirtualHost;
    property ClientID: String read FClientID write FClientID;
    property AcceptVersion: TStompAcceptProtocol read FAcceptVersion;
    property UserName: String read FUserName write FUserName;
    property Password: String read FPassword write FPassword;
  end;

const
  SMSG_ERRO_SINGLETON = 'Use method getInstance for instace class. This class is singleton';
  SDEFAULT_USERNAME = 'guest';
  SDEFAULT_PASSWORD = 'guest';

implementation

{ TSTOMPRouteServer }
procedure TSTOMPRouteServer.connect;
begin
  setListeners;
end;

constructor TSTOMPRouteServer.Create;
begin
  Inherited;
  if Assigned(FInstance) then
    raise Exception.Create(SMSG_ERRO_SINGLETON);

  FInstance := Self;
  FListProcessor := TList<TStompProcessor>.Create;

  FHost := DEFAULT_STOMP_HOST;
  FPort := DEFAULT_STOMP_PORT;
  FVirtualHost := EmptyStr;
  FClientID := EmptyStr;
  FAcceptVersion := TStompAcceptProtocol.Ver_1_0;
  FUserName := SDEFAULT_USERNAME;
  FPassword := SDEFAULT_PASSWORD;

  FSTOMPRoute := TSTOMPRouteSubscribe.create;
end;

destructor TSTOMPRouteServer.Destroy;
begin
  ReleaseProcessors;
  FreeAndNil(FSTOMPRoute);
  inherited;
end;

procedure TSTOMPRouteServer.Disconnect;
begin
  Self.Free;
end;

class function TSTOMPRouteServer.GetInstance: TSTOMPRouteServer;
begin
  if Not(Assigned(FInstance)) then
    TSTOMPRouteServer.Create;

  result := FInstance;
end;

function TSTOMPRouteServer.NewStompClient: IStompClient;
begin
  result := StompUtils.StompClient
                    .SetHost(Host)
                    .SetPort(Port)
                    .SetVirtualHost(VirtualHost)
                    .SetClientID(ClientID)
                    .SetAcceptVersion(AcceptVersion)
                    .SetUserName(UserName)
                    .SetPassword(Password)
                    .Connect;
end;

procedure TSTOMPRouteServer.ReleaseProcessors;
var
  oStompRoute : TStompProcessor;
begin
  for oStompRoute in FListProcessor do
    oStompRoute.Free;

  FreeAndNil(FListProcessor);
end;

procedure TSTOMPRouteServer.SetListeners;
var
  oStompProcessor : TStompProcessor;
begin
  for oStompProcessor in FListProcessor do
  begin
    oStompProcessor.STOMPClient := newStompClient;
    oStompProcessor.STOMPClient.Subscribe(oStompProcessor.route, oStompProcessor.Ack, oStompProcessor.Headers);
    oStompProcessor.Listener := StompUtils.CreateListener(oStompProcessor.STOMPClient, oStompProcessor);
    oStompProcessor.Listener.StartListening;
  end;
end;

procedure TSTOMPRouteServer.Subscribe(opStompProcessor: TStompProcessor);
begin
  FListProcessor.Add(opStompProcessor);
end;

class procedure TSTOMPRouteServer.SubscribeProcessor(opStompProcessor: TStompProcessor);
begin
  TSTOMPRouteServer.getInstance.Subscribe(opStompProcessor);
end;

initialization
  TSTOMPRouteServer.GetInstance;

finalization
  if Assigned(TSTOMPRouteServer.FInstance) Then
    TSTOMPRouteServer.FInstance.free;


end.
