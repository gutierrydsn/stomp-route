unit stomp.route.processor;

interface

uses
  System.SysUtils, System.Variants, System.Classes, System.Types, StompClient;

type
  IStompProcessor = interface
    function GetHeaders: IStompHeaders;
    function GetAck: TAckMode;
    function GetListener: IStompListener;
    function GetStompClient: IStompClient;
    function GetNomeDaFilaDeErro : String;
    function GetRoute : String;

    procedure Setup;
    procedure TearDown;
    procedure SetListener(value : IStompListener);
    procedure SetStompClient(value : IStompClient);
    procedure SetRoute(value : String);
    procedure SendErro(sMsgErro : String; StompFrame: IStompFrame);

    property Headers: IStompHeaders read getHeaders;
    property Ack: TAckMode read getAck;
    property Listener : IStompListener read getListener write setListener;
    property STOMPClient: IStompClient read getStompClient write setStompClient;
    property Route: String read GetRoute write SetRoute;
  end;

  TStompProcessor = class(TInterfacedPersistent, IStompProcessor, IStompClientListener)
  private
    FListener : IStompListener;
    FSTOMPClient: IStompClient;
    FRoute : String;
  protected
    function GetHeaders: IStompHeaders;
    function GetAck: TAckMode;virtual;
    function GetListener: IStompListener;
    function GetStompClient: IStompClient;
    function getNomeDaFilaDeErro : String; virtual;
    function GetRoute : String;

    procedure SetListener(value : IStompListener);
    procedure SetStompClient(value : IStompClient);
    procedure SetRoute(value : String);
    procedure PrepareHeader(opHeaders : IStompHeaders);virtual;
    procedure SendErro(sMsgErro : String; StompFrame: IStompFrame);
  public
    procedure Setup; virtual;
    procedure TearDown; virtual;
    procedure OnMessage(StompFrame: IStompFrame; var TerminateListener: Boolean);virtual; abstract;
    procedure OnListenerStopped(StompClient: IStompClient);virtual; abstract;

    destructor Destroy; override;
  published
    property Headers : IStompHeaders read getHeaders;
    property Ack : TAckMode read getAck;
    property Listener : IStompListener read getListener write setListener;
    property STOMPClient: IStompClient read getStompClient write setStompClient;
    property Route: String read GetRoute write SetRoute;
  end;

implementation

{ TStompProcessor }
destructor TStompProcessor.Destroy;
begin
  TearDown;
  inherited;
end;

function TStompProcessor.getAck: TAckMode;
begin
  result := amAuto;
end;

function TStompProcessor.getHeaders: IStompHeaders;
var
  IHeaders : IStompHeaders;
begin
  IHeaders := StompUtils.Headers;
  prepareHeader(IHeaders);

  result := IHeaders;
end;

function TStompProcessor.getListener: IStompListener;
begin
  result := FListener;
end;

function TStompProcessor.getNomeDaFilaDeErro: String;
begin
  result := GetRoute + '_ERROR';
end;

function TStompProcessor.GetRoute: String;
begin
  result := FRoute;
end;

function TStompProcessor.getStompClient: IStompClient;
begin
  result := FSTOMPClient;
end;

procedure TStompProcessor.PrepareHeader(opHeaders: IStompHeaders);
begin
 //ADD HEADERS DEFAULT
end;

procedure TStompProcessor.SendErro(sMsgErro : String; StompFrame: IStompFrame);
const
  SMSG_ERROR = '{"error" : "%s", "msg_origem" : "%s"}';
begin
  STOMPClient.Send(GetNomeDaFilaDeErro, Format(SMSG_ERROR, [sMsgErro, StompFrame.Body]));
  STOMPClient.Ack(StompFrame.MessageID);
end;

procedure TStompProcessor.setListener(value: IStompListener);
begin
  FListener := value;
end;

procedure TStompProcessor.SetRoute(value: String);
begin
  FRoute := value;
end;

procedure TStompProcessor.setStompClient(value: IStompClient);
begin
  FSTOMPClient := value;
end;

procedure TStompProcessor.Setup;
begin
 //ADD BLOCO DE INICIALIZAÇÃO DEFAULT
end;

procedure TStompProcessor.TearDown;
begin
 //ADD BLOCO DE FINALIZAÇÃO DEFAULT
end;

end.
