program test;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  XSuperObject,
  Windows, Classes,
  Net.HttpClient,
  Net.HttpClientComponent,
  CoomerParty.Types in '..\source\CoomerParty.Types.pas',
  CoomerParty.HTMLParser in '..\source\CoomerParty.HTMLParser.pas',
  CoomerParty.Scraper in '..\source\CoomerParty.Scraper.pas';

const
  PRINT_RESULT = false;
  PRINT_BIG_DATA = false;

procedure WritelnWA(AStr: string; AAttrs: word);
var
  h: cardinal;
begin
  h := GetStdHandle(STD_OUTPUT_HANDLE);
  SetConsoleTextAttribute(h, AAttrs);
  Writeln(AStr);
  SetConsoleTextAttribute(h, 7);
end;

procedure WritelnB(AStr: string; AGood: boolean);
begin
  if AGood then
    WritelnWA(AStr + ' OKEY ', 10)
  else
    WritelnWA(AStr + ' PROBLEM ', 14);
end;

procedure Print(const A: TPartyArtistAr); overload;
var
  I: integer;
begin
  for i := 0 to Length(A) - 1 do begin
    Writeln('[' + I.ToString + '] ' + TJson.Stringify<TPartyArtist>(A[i], false));
  end;
end;

procedure Print(const A: TPartyPostAr); overload;
var
  I: integer;
begin
  for i := 0 to Length(A) - 1 do begin
    Writeln('[' + I.ToString + '] ' + TJson.Stringify<TPartyPost>(A[i], false));
  end;
end;

procedure Print(const A: TPartyPostsPage); overload;
var
  I: integer;
begin
//  for i := 0 to high(A.Posts) do
//    Writeln(A.Posts[I].PostUrl(URL_COOMER_PARTY));
  Writeln(TJson.Stringify<TPartyPostsPage>(A, true));
end;

procedure Print(const A: TPartyPostPage); overload;
var
  I: integer;
begin
  Writeln(TJson.Stringify<TPartyPostPage>(A, true));
end;

function NewScraper: TCoomerPartyScraper;
begin
  Result := TCoomerPartyScraper.Create;
  with Result.Client do begin
    Asynchronous := false;
    AutomaticDecompression := [THttpCompressionMethod.Any];
    AllowCookies := false;
    Useragent                        := 'Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0';
    Customheaders['Accept']          := 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8';
    CustomHeaders['Accept-Language'] := 'en-US,en;q=0.5';
    CustomHeaders['Accept-Encoding'] := 'gzip, deflate';
    CustomHeaders['DNT']             := '1';
    CustomHeaders['Connection']      := 'keep-alive';
    CustomHeaders['Upgrade-Insecure-Requests'] := '1';
    CustomHeaders['Sec-Fetch-Dest']  := 'document';
    CustomHeaders['Sec-Fetch-Mode']  := 'navigate';
    CustomHeaders['Sec-Fetch-Site']  := 'same-origin';
    CustomHeaders['Pragma']          := 'no-cache';
    CustomHeaders['Cache-Control']   := 'no-cache';
  end;
end;

procedure TestScraper(AHost, AArtistId, AService: string; APrintResult: boolean = PRINT_RESULT);
var
  Party: TCoomerPartyScraper;
  Artists: TPartyArtistAr;
  ArtistsPage: TPartyArtistsPage;
  PostsPage: TPartyPostsPage;
  PostPage: TPartyPostPage;
  L: integer;
begin
  Party := NewScraper;
  Party.Host := AHost;

  Write(Party.Host + ': GetRecentPostsByPageNum (With text query): ');
  PostsPage := Party.GetRecentPostsByPageNum('valorant', 1);
  L := Length(PostsPage.Posts);
  WritelnB(L.ToString, (L > 0));
  if APrintResult then Print(PostsPage);

  Write(Party.Host + ': GetPost: ');
  PostPage := party.GetPost(PostsPage.Posts[0]);
  WritelnB(Length(PostPage.Files).ToString, ( not PostPage.Author.Id.IsEmpty ));
  if APrintResult then Print(PostPage);

  Write(Party.Host + ': GetArtistPostsByPageNum: ');
  PostsPage := Party.GetArtistPostsByPageNum('', AArtistId, AService, 1);
  L := Length(PostsPage.Posts);
  WritelnB(L.ToString, (L > 0));
  if APrintResult then Print(PostsPage);

  Write(Party.Host + ': GetRecentPostsByPageNum: ');
  PostsPage := Party.GetRecentPostsByPageNum('', 1);
  L := Length(PostsPage.Posts);
  WritelnB(L.ToString, (L > 0));
  if APrintResult then Print(PostsPage);

  Write(Party.Host + ': GetArtistsByPageNum: ');
  ArtistsPage := Party.GetArtistsByPageNum(1);
  L := Length(ArtistsPage.Artists);
  WritelnB(L.ToString, ( L > 0 ));
  if APrintResult then Print(ArtistsPage.Artists);

  Write(Party.Host + ': GetAllArtists: ');
  Artists := Party.GetAllArtists;
  L := Length(Artists);
  WritelnB(L.ToString, ( L > 0 ));
  if ( APrintResult and PRINT_BIG_DATA) then Print(Artists);
end;


begin
  try
    TestScraper(URL_COOMER_PARTY, 'femboygaming', 'onlyfans');
    TestScraper(URL_KEMONO_PARTY, '755183', 'patreon');
    Writeln('FIN!');
    Readln;
  except
    on E: Exception do begin
      Writeln(E.ClassName, ': ', E.Message);
      readln;
    end;
  end;
end.
