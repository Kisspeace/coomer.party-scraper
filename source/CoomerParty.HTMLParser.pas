//♡2022 by Kisspeace. https://github.com/kisspeace
unit CoomerParty.HTMLParser;

interface
uses
  Sysutils, CoomerParty.Types, Classes,
  {*Net.Encoding*}
  NetEncoding,
  {*htmlparser*}
  HtmlParserEx;

const
  DATETIME_FORMAT: TFormatSettings = (
    DateSeparator: '-';
    TimeSeparator: ':';
    ShortDateFormat: 'YYYY-MM-DD';
    ShortTimeFormat: 'HH:MM:SS';
  );

  function ParseArtistsFromNodes(ANodes: IHtmlElementList): TPartyArtistAr;
  function ParseArtistsPage(const AContent: string): TPartyArtistsPage;

  function ParsePostsFromNodes(ANodes: IHtmlElementList): TPartyPostAr;
  function ParsePostsPage(const AContent: string): TPartyPostsPage;

  function ParsePostPage(const AContent: string): TPartyPostPage;

implementation

function GetElementByClass(AElement: IHtmlElement; AClass: string): IHtmlElement;
var
  List: IHtmlElementList;
begin
  List := AElement.FindX('//*[@class="' + AClass + '"]');
  if ( List.Count > 0 ) then
    Result := List.Items[0]
  else
    Result := Nil;
end;

function ParseTimestamp(AElement: IHtmlElement): TDateTime;
var
  E: IHtmlElement;
begin
  E := GetElementByClass(AElement, 'timestamp');
  Result := StrToDateTime(E.Attributes['datetime'], DATETIME_FORMAT);
end;

function ParseArtistsFromNodes(ANodes: IHtmlElementList): TPartyArtistAr;
var
  I, I2: integer;
  Els: IHtmlElementList;
  N, E, Tmp: IHtmlElement;
  s: string;
begin
  for I := 0 to ( ANodes.Count - 1 ) do begin

    E := ANodes.items[I];
    s := E.Attributes['data-id']; // Artist Id

    if ( not s.IsEmpty ) then begin
      var LArtist: TPartyArtist;
      LArtist := TPartyArtist.New;
      LArtist.Id := s;
      LArtist.Service := E.Attributes['data-service'];

      //Artist name
      try
        Tmp := E.FindX('//*[@class="user-card__name"]/a')[0];
        LArtist.Name := Tmp.Text;
      except

      end;


      Result := Result + [LArtist];
    end;
  end;
end;

function ParseArtistsPage(const AContent: string): TPartyArtistsPage;
var
  Doc: IHTMLElement;
  Nodes: IHTMLElementList;
begin
  Result := TPartyArtistsPage.New;
  Doc := ParserHTML(AContent);
  Nodes := Doc.FindX('body/*[@class="user-card"]');
  Result.Artists := ParseArtistsFromNodes(Nodes);
end;

function ParsePostsFromNodes(ANodes: IHtmlElementList): TPartyPostAr;
var
  I: integer;
  E, Tmp: IHtmlElement;
  Tmps: IHtmlElementList;
begin
  for I := 0 to ( ANodes.Count - 1 ) do begin
    E := ANodes.Items[I];

    var LPost: TPartyPost;
    LPost := TPartyPost.New;

    LPost.Id := StrToint64(E.Attributes['data-id']);
    LPost.Author.Id := E.Attributes['data-user'];
    LPost.Author.Service := E.Attributes['data-service'];

    //Thumbnail
    Tmp := GetElementByClass(E, 'post-card__image');
    if Assigned(Tmp) then begin
      LPost.Thumbnail := Tmp.Attributes['src'];
    end;

    //Content text
    Tmps := E.FindX('//*[@class="post-card__heading"]');
    if ( Tmps.Count > 0 ) then begin
      Tmp := Tmps[0];
      if Assigned(Tmp) then
        LPost.Content := trim(Tmp.Text);
    end;

    //Timestamp
    try
      LPost.Timestamp := ParseTimestamp(E);
    except

    end;

    Result := Result + [LPost];
  end;
end;

function ParsePostsPage(const AContent: string): TPartyPostsPage;
var
  Doc: IHtmlElement;
  Nodes: IHtmlElementList;
begin
  Result := TPartyPostsPage.New;
  Doc := ParserHTML(AContent);
  Nodes := Doc.FindX('body/*[@class="card-list__items"]/article');
  Result.Posts := ParsePostsFromNodes(Nodes);
end;

function ParsePostPage(const AContent: string): TPartyPostPage;
var
  Doc, E, Tmp: IHtmlElement;
  Nodes: IHtmlElementList;
  Str: string;
  I: integer;

  function Between(const ASource: string; AFirst, ASecond: string): string;
  var
    L, N, N2: integer;
  begin
    Result := '';
    L := Length(ASource);
    N := Pos(AFirst, ASource);
    if ( N > (Low(String) - 1) ) then begin
      N := N + Length(AFirst);
      N2 := Pos(ASecond, ASource, N);
      Result := Copy(ASource, N, N2 - N);
    end;
  end;

  function After(const ASource: string; ASub: string): string;
  var
    L, N: integer;
  begin
    Result := '';
    L := Length(ASource);
    N := Pos(ASub, ASource);
    if ( N > (Low(String) - 1) ) then
      Result := Copy(ASource, N + Length(ASub), L);
  end;

begin
  Result := TPartyPostPage.New;
  Doc := ParserHTML(AContent);

  E := Doc.FindX('body/*[@class="post__header"]')[0];

  // About artist
  Tmp := GetElementByClass(E, 'post__user-name');
  Result.Author.Name := trim(Tmp.Text);
  Str := Tmp.Attributes['href'];
  Result.Author.Service := Between(Str, '/', '/user/');
  Result.Author.Id := After(Str, '/user/');

  // Timestamp
  try
    Result.Timestamp := ParseTimestamp(E);
  except

  end;

  // Content
  Nodes := Doc.FindX('body/*[@class="post__content"]/pre');
  if ( Nodes.Count > 0 ) then begin
    Result.Content := Nodes[0].Text;
  end;

  // Thumbnails and full image urls
  Nodes := Doc.FindX('body/*[@class="fileThumb"]');
  for I := 0 to Nodes.Count - 1 do begin
    Result.Files := Result.Files + [Nodes[I].Attributes['href']];
    try
      Tmp := Nodes[I].Find('img')[0];
      Result.Thumbnails := Result.Thumbnails + [Tmp.Attributes['src']];
    except

    end;
  end;

  // Attachments
  Nodes := Doc.FindX('body/*[@class="post__attachment-link"]');
  for I := 0 to Nodes.Count - 1 do
    Result.Files := Result.Files + [Nodes[I].Attributes['href']];

end;

end.
