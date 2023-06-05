//♡2022 by Kisspeace. https://github.com/kisspeace
unit CoomerParty.Scraper;

interface
uses
  classes, Sysutils, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent,
  system.Generics.Collections, XSuperObject,
  CoomerParty.HTMLParser, CoomerParty.Types;

const
  ITEMS_PER_PAGE = 25;

  URL_COOMER_PARTY = 'https://coomer.party';
  URL_KEMONO_PARTY = 'https://kemono.party';
  URL_COOMER_SU = 'https://coomer.su';
  URL_KEMONO_SU = 'https://kemono.su';

type

  TCoomerPartyScraper = class(TObject)
    private const
      DEFAULT_HOST = URL_COOMER_PARTY;
    private
      FHost: string;
      function GetParams(AQuery: string; AStartFrom: integer): string;
      function PageIdFromNum(APageNum: integer): integer;
    public
      Client: TNetHttpClient;
      {* JSON API *}
      function GetAllArtists: TPartyArtistAr;
      {* from HTML *}
      function GetArtists(AStartFrom: integer = 0): TPartyArtistsPage;
      function GetArtistsByPageNum(APage: integer = 1): TPartyArtistsPage;
      {*-----------*}
      function GetRecentPosts(AQuery: string; AStartFrom: integer = 0): TPartyPostsPage;
      function GetRecentPostsByPageNum(AQuery: string; APage: integer = 1): TPartyPostsPage;
      {*-----------*}
      function GetArtistPosts(AQuery, AArtistId, AService: string; AStartFrom: integer = 0): TPartyPostsPage; overload;
      function GetArtistPosts(AQuery: string; const AArtist: TPartyArtist; AStartFrom: integer = 0): TPartyPostsPage; overload;
      function GetArtistPostsByPageNum(AQuery, AArtistId, AService: string; APage: integer = 1): TPartyPostsPage; overload;
      function GetArtistPostsByPageNum(AQuery: string; const AArtist: TPartyArtist; APage: integer = 1): TPartyPostsPage; overload;
      {* --------- *}
      function GetPost(AArtistId, AService: string; APostId: int64): TPartyPostPage; overload;
      function GetPost(const AArtist: TPartyArtist; APostId: int64): TPartyPostPage; overload;
      function GetPost(const APost: TPartyPost): TPartyPostPage; overload;
      {* --------- *}
      property Host: string read FHost write FHost;
      constructor Create;
      destructor Destroy; override;
  end;

implementation

{ TCoomerPartyScraper }

constructor TCoomerPartyScraper.Create;
begin
  Client := TNetHttpClient.Create(Nil);
  Client.Asynchronous := false;
  FHost := DEFAULT_HOST;
end;

destructor TCoomerPartyScraper.Destroy;
begin
  Client.Free;
end;

function TCoomerPartyScraper.GetAllArtists: TPartyArtistAr;
var
  LContent: string;
begin
  LContent := Client.Get(Self.Host + '/api/creators').ContentAsString;
  Result := TJson.Parse<TPartyArtistAr>(LContent);
end;

function TCoomerPartyScraper.GetArtistPosts(AQuery, AArtistId, AService: string;
  AStartFrom: integer): TPartyPostsPage;
var
  LContent: string;
begin
  LContent := Client.Get(Self.Host + '/' + AService + '/user/' + AArtistId + Self.GetParams(AQuery, AStartFrom)).ContentAsString;
  Result := ParsePostsPage(LContent);
end;

function TCoomerPartyScraper.GetArtistPosts(AQuery: string; const AArtist: TPartyArtist;
  AStartFrom: integer): TPartyPostsPage;
begin
  Result := Self.GetArtistPosts(AQuery, AArtist.Id, AArtist.Service, AStartFrom);
end;

function TCoomerPartyScraper.GetArtistPostsByPageNum(AQuery, AArtistId,
  AService: string; APage: integer): TPartyPostsPage;
begin
  Result := Self.GetArtistPosts(AQuery, AArtistId, AService, PageIdFromNum(APage));
end;

function TCoomerPartyScraper.GetArtistPostsByPageNum(AQuery: string; const AArtist: TPartyArtist;
  APage: integer): TPartyPostsPage;
begin
   Result := Self.GetArtistPosts(AQuery, AArtist.Id, AArtist.Service, PageIdFromNum(APage));
end;

function TCoomerPartyScraper.GetArtists(AStartFrom: integer): TPartyArtistsPage;
var
  LContent: string;
begin
  LContent := Client.Get(Self.Host + '/artists' + Self.GetParams('', AStartFrom)).ContentAsString;
  Result := ParseArtistsPage(LContent);
end;

function TCoomerPartyScraper.GetArtistsByPageNum(
  APage: integer): TPartyArtistsPage;
begin
  Result := Self.GetArtists(PageIdFromNum(APage));
end;

function TCoomerPartyScraper.GetParams(AQuery: string;
  AStartFrom: integer): string;
begin
  Result := '?o=' + AStartFrom.ToString;
  if ( not AQuery.IsEmpty ) then
    Result := Result + '&q=' + AQuery;
end;

function TCoomerPartyScraper.GetPost(const AArtist: TpartyArtist;
  APostId: int64): TPartyPostPage;
begin
  Result := Self.GetPost(AArtist.Id, AArtist.Service, APostId)
end;

function TCoomerPartyScraper.GetPost(AArtistId, AService: string;
  APostId: int64): TPartyPostPage;
var
  LContent: String;
begin
  LContent := Client.Get(Self.Host + '/' + AService + '/user/' + AArtistId + '/post/' + APostId.ToString).ContentAsString;
  Result := ParsePostPage(LContent);
end;

function TCoomerPartyScraper.GetRecentPosts(AQuery: string; AStartFrom: integer): TPartyPostsPage;
var
  LContent: string;
begin
  LContent := Client.Get(Self.Host + '/posts' + Self.GetParams(AQuery, AStartFrom)).ContentAsString;
  Result := ParsePostsPage(LContent);
end;

function TCoomerPartyScraper.GetRecentPostsByPageNum(AQuery: string; APage: integer): TPartyPostsPage;
begin
  Result := Self.GetRecentPosts(AQuery, PageIdFromNum(APage));
end;

function TCoomerPartyScraper.PageIdFromNum(APageNum: integer): integer;
begin
  if ( APageNum >= 1 ) then Dec(APageNum);
  Result := ( APageNum * ITEMS_PER_PAGE );
end;

function TCoomerPartyScraper.GetPost(const APost: TPartyPost): TPartyPostPage;
begin
  result := Self.GetPost(APost.Author.Id, APost.Author.Service, APost.Id);
end;

end.
