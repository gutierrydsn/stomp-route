unit stomp.route.subscribe;

interface

uses
  System.SysUtils, System.Variants, System.Classes, System.Types, StompClient, System.JSON,
  stomp.route.processor, System.Rtti;

type
  TSTOMPRouteSubscribe = class
  private
    class var FInstance : TSTOMPRouteSubscribe;

    procedure loadFileConfig;
    function identifyProcessor(opPair: TJSONPair): TStompProcessor;
  public

    constructor Create;
    destructor Destroy; override;

    class function getInstance : TSTOMPRouteSubscribe;
  published
  end;

implementation
uses stomp.route.server;


{ TSTOMPRouteSubscribe }
constructor TSTOMPRouteSubscribe.Create;
begin
  if Assigned(FInstance) then
    raise Exception.Create('Use method getInstance for instace class. This class is singleton');

  loadFileConfig;
end;

destructor TSTOMPRouteSubscribe.Destroy;
begin

  inherited;
end;

procedure TSTOMPRouteSubscribe.loadFileConfig;
var
  list: TStringList;
  JSON: TJSONObject;
  i: integer;
begin
  list := TStringList.Create;
  try
    list.LoadFromStream(TResourceStream.Create(HInstance, 'routes', RT_RCDATA));

    json := TJSONObject(TJSONObject.ParseJSONValue('{'+list.Text+'}'));

    for i := 0 to json.Count-1 do
      TSTOMPRouteServer.SubscribeProcessor(identifyProcessor(TJSONPair(json.Pairs[i])));

  finally
    FreeAndNil(json);
    FreeAndNil(list);
  end;
end;

function TSTOMPRouteSubscribe.identifyProcessor(opPair : TJSONPair) : TStompProcessor;
const
  SMSG_ERRO_INSTANCE = 'Problema ao instanciar o processador, processador não encontrado!';
  SMSG_ERRO_TIPO_CLASSE = 'A Classe instaciada é diferente de um TController';
var
  sRoute: String;
  sProcessor: String;
  oContext : TRttiContext;
  oProcessor  : TStompProcessor;
begin
  sRoute  := opPair.JsonString.ToString.Replace('"', EmptyStr);
  sProcessor := opPair.JsonValue.ToString.Replace('"', EmptyStr);

  try
    oProcessor := (oContext.FindType(sProcessor) as TRttiInstanceType).MetaClassType.Create as TStompProcessor;
    oProcessor.Setup;
  except
    raise Exception.Create(SMSG_ERRO_INSTANCE);
  end;

  if not(Assigned(oProcessor))  then
    raise Exception.Create(SMSG_ERRO_INSTANCE);

  if Not(oProcessor.InheritsFrom(TStompProcessor))  then
    raise Exception.Create(SMSG_ERRO_TIPO_CLASSE);

  oProcessor.route := sRoute;

  result := oProcessor;
end;


class function TSTOMPRouteSubscribe.getInstance: TSTOMPRouteSubscribe;
begin
  if Not(Assigned(FInstance)) then
    FInstance := TSTOMPRouteSubscribe.Create;

  result := FInstance;
end;

end.
