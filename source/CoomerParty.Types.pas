//♡2022 by Kisspeace. https://github.com/kisspeace
unit CoomerParty.Types;

interface
uses
  Sysutils, XSuperObject;

type

  TPartyArtist = record
    public
      [ALIAS('id')] Id: string;
      //[ALIAS('indexed')] Indexed: TDateTime;
      [ALIAS('name')] Name: string;
      [ALIAS('service')] Service: string;
      //[ALIAS('updated')] Updated: TDateTime;
      class function New: TPartyArtist; static;
  end;

  TPartyArtistAr = TArray<TPartyArtist>;

  TPartyArtistsPage = record
    public
      TotalCount: Cardinal;
      Artists: TPartyArtistAr;
      class function New: TPartyArtistsPage; static;
  end;

  TPartyPost = record
    public
      Id: int64;
      Author: TPartyArtist;
      Content: string;
      //AttachmentsCount: integer;
      //PostUrl: string;
      Thumbnail: string;
      Timestamp: TDateTime;
      function PostUrl(AHost: string): string;
      //function HasAttachments: boolean;
      class function New: TPartyPost; static;
  end;

  TPartyPostAr = TArray<TPartyPost>;

  TPartyPostsPage = record
    public
      TotalCount: cardinal;
      Posts: TPartyPostAr;
      class function New: TPartyPostsPage; static;
  end;

  TPartyPostPage = record
    public
      Author: TPartyArtist;
      Content: string;
      Timestamp: TDateTime;
      Thumbnails: TArray<String>;
      Files: TArray<String>;
      class function New: TPartyPostPage; static;
  end;

implementation

{ TPartyArtist }

class function TPartyArtist.New: TPartyArtist;
begin
  Result.Id := '';
  Result.Name := '';
  Result.Service := '';
end;

{ TPartyArtistsPage }

class function TPartyArtistsPage.New: TPartyArtistsPage;
begin
  Result.TotalCount := 0;
  Result.Artists := [];
end;

{ TPartyPost }

class function TPartyPost.New: TPartyPost;
begin
  Result.Id := -1;
  Result.Author := TPartyArtist.New;
  Result.Content := '';
  //Result.AttachmentsCount := 0;
  //Result.PostUrl := '';
  Result.Thumbnail := '';
  Result.Timestamp := -1;
end;

function TPartyPost.PostUrl(AHost: string): string;
begin
  Result :=  AHost + '/' + self.Author.Service + '/user/' + Self.Author.Id + '/post/' + Self.Id.ToString;
end;

{ TPartyPostsPage }

class function TPartyPostsPage.New: TPartyPostsPage;
begin
  Result.TotalCount := 0;
  Result.Posts := [];
end;

{ TPartyFullPost }

class function TPartyPostPage.New: TPartyPostPage;
begin
  Result.Author := TPartyArtist.New;
  Result.Content := '';
  Result.Timestamp := -1;
  Result.Thumbnails := [];
  Result.Files := [];
end;

end.
