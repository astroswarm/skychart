unit vocat;

{$mode objfpc}{$H+}

interface

uses  skylibcat, gcatunit, XMLRead, DOM, math, XMLConf,
  Classes, SysUtils; 

procedure SetVOCatpath(path:string);
Procedure OpenVOCat(ar1,ar2,de1,de2: double ; var ok : boolean);
Procedure OpenVOCatwin(var ok : boolean);
Procedure ReadVOCat(var lin : GCatrec; var ok : boolean);
Procedure NextVOCat( var ok : boolean);
procedure CloseVOCat ;

type TFieldData = class(Tobject)
     name, ucd, datatype, units, description : string;
     end;

var
   VOobject : string;
   VOCatpath : string ='';
   deffile,catfile: string;
   Defsize: integer;
   Defmag: double;
   active,VODocOK: boolean;
   drawtype: integer;
   drawcolor: integer;
   flabels: Tlabellst;
   unitpmra, unitpmdec: double;
   catname:string;
   VOcatlist : TStringList;
   VOFields: TStringList;
   Ncat, CurCat, catversion: integer;
   emptyrec : gcatrec;
   VODoc: TXMLDocument;
   VoNode: TDOMNode;

implementation

procedure SetVOCatpath(path:string);
begin
VOCatpath:=noslash(path);
end;

Procedure InitRec;
var n : integer;
    ucd: string;
begin
  emptyrec.options.rectype:=catversion;
  emptyrec.options.Equinox:=2000;
  emptyrec.options.EquinoxJD:=jd2000;
  JDCatalog:=emptyrec.options.EquinoxJD;
  emptyrec.options.Epoch:=2000;
  emptyrec.options.MagMax:=20;
  emptyrec.options.Size:=Defsize;
  emptyrec.options.Units:=60;
  emptyrec.options.ObjType:=1;
  emptyrec.options.LogSize:=0;
  emptyrec.options.UsePrefix:=0;
  for n:=1 to 10 do emptyrec.options.altname[n]:=false;
  emptyrec.options.flabel:=flabels;
  emptyrec.options.flabel[lOffset+vsComment]:='File';
  emptyrec.options.ShortName:='VO';
  case emptyrec.options.rectype of
  rtstar : begin
           emptyrec.star.magv:=-99;
           emptyrec.star.valid[vsId]:=true;
           emptyrec.star.valid[vsComment]:=true;
           if unitpmra<>0 then emptyrec.star.valid[vsPmra]:=true;
           if unitpmdec<>0 then emptyrec.star.valid[vsPmdec]:=true;
      end;
  rtneb : begin
          emptyrec.neb.valid[vnId]:=true;
          emptyrec.neb.valid[vnComment]:=true;
          emptyrec.neb.valid[vnNebtype]:=true;
          emptyrec.neb.valid[vnMag]:=true;
          emptyrec.neb.valid[vnDim1]:=true;
          emptyrec.neb.nebtype:=drawtype;
          emptyrec.neb.mag:=Defmag;
          emptyrec.neb.dim1:=Defsize;
      end;
  end;
end;

Procedure Getkeyword(s: string; var k,v:string);
var p: integer;
begin
p:=pos('=',s);
if p=0 then
  v:=s
else begin
  k:=trim(copy(s,1,p-1));
  v:=trim(copy(s,p+1,999));
end;
end;

Function ReadVOHeader: boolean;
var buf,e,k,v:string;
    u: double;
    i,j: integer;
    fieldnode: TDOMNode;
    fielddata: TFieldData;
    config: TXMLConfig;
begin
result:=false;
fillchar(EmptyRec,sizeof(GcatRec),0);
unitpmra:=0;
unitpmdec:=0;
catname:=ExtractFileName(catfile);
config:=TXMLConfig.Create(nil);
config.Filename:=deffile;
VOobject:=config.GetValue('objtype',VOobject);
active:=config.GetValue('active',false);
drawtype:=config.GetValue('drawtype',14);
drawcolor:=config.GetValue('drawcolor',$FF0000);
DefSize:=config.GetValue('defsize',60);
Defmag:=config.GetValue('defmag',10);
config.free;
if FileExists(catfile) then begin
try
ReadXMLFile( VODoc, catfile);
VODocOK:=true;
VoNode:=VODoc.DocumentElement.FindNode('RESOURCE');
VoNode:=VoNode.FindNode('TABLE');
VoNode:=VoNode.FirstChild;
VOFields.Clear;
while Assigned(VoNode) do begin
  buf:=VoNode.NodeName;
  if buf='FIELD' then begin
    fielddata:=TFieldData.Create;
    fieldnode:=VoNode.FindNode('DESCRIPTION');
    if fieldnode<>nil then begin
       fielddata.description:=fieldnode.TextContent;
    end;
    fieldnode:=VoNode.Attributes.GetNamedItem('name');
    if fieldnode<>nil then k:=fieldnode.NodeValue;
    fielddata.name:=k;
    fieldnode:=VoNode.Attributes.GetNamedItem('ucd');
    if fieldnode<>nil then fielddata.ucd:=fieldnode.NodeValue;
    fieldnode:=VoNode.Attributes.GetNamedItem('datatype');
    if fieldnode<>nil then fielddata.datatype:=fieldnode.NodeValue;
    fieldnode:=VoNode.Attributes.GetNamedItem('unit');
    if fieldnode<>nil then fielddata.units:=fieldnode.NodeValue;
    VOFields.AddObject(k,fielddata);
    if pos('pos.pm',fielddata.ucd)>0 then begin
      i:=pos('/',fielddata.units);
      k:=copy(fielddata.units,1,i-1);
      v:=copy(fielddata.units,i+1,99);
      if copy(k,1,2)='10' then begin
         e:=Copy(k,3,2);
         k:=Copy(k,5,99);
         u:=StrToFloatDef(e,-99999);
         if u<>-99999 then u:=power(10,(u))
            else u:=0;
      end
      else u:=1;
      if k='mas' then u:=u/3600/1000
      else if k='arcsec' then u:=u/3600
      else if k='arcmin' then u:=u/60
      else if k<>'deg' then u:=0;
      if (v<>'a')and(v<>'yr') then u:=0;
      if pos('pos.eq.ra',fielddata.ucd)>0 then begin
          unitpmra:=deg2rad*u;
          flabels[lOffset+vsPmra]:=fielddata.name;
       end
       else if pos('pos.eq.dec',fielddata.ucd)>0 then begin
          unitpmdec:=deg2rad*u;
          flabels[lOffset+vsPmdec]:=fielddata.name;
       end;
    end;

  end;
  if buf='DATA' then break;
  VoNode:=VoNode.NextSibling;
end;
VoNode:=VoNode.FirstChild;   // TABLEDATA
VoNode:=VoNode.FirstChild;   // first TR
if Assigned(VoNode) then begin
  buf:=VoNode.NodeName;
  if buf='TR' then begin
    result:=true;
    if VOobject='star' then catversion:=rtStar;
    if VOobject='dso'  then catversion:=rtNeb;
    InitRec;
  end;
end;
except
  result:=false;
end;
end;
end;

Procedure OpenVOCat(ar1,ar2,de1,de2: double ; var ok : boolean);
begin
OpenVOCatwin(ok);
end;

Procedure OpenVOCatwin(var ok : boolean);
var fs: TSearchRec;
    i: integer;
begin
ok:=false;
VOcatlist:=TStringList.Create;
VOFields:=TStringList.Create;
Ncat:=0;
VODocOK:=false;
i:=findfirst(slash(VOCatpath)+'vo_table_'+VOobject+'_*.xml',0,fs);
while i=0 do begin
  VOcatlist.Add(fs.Name);
  inc(Ncat);
  i:=findnext(fs);
end;
findclose(fs);
CurCat:=-1;
NextVOCat(ok);
end;

Procedure ReadVOCat(var lin : GCatrec; var ok : boolean);
var row: TDOMNode;
    buf: string;
    i: integer;
begin
ok:=false;
lin:=emptyrec;
if Assigned(VoNode) then begin
  row:=VoNode.FirstChild;
  i:=0;
  case catversion of
  rtStar: begin
          lin.star.comment:=catname+tab;
          end;
  rtNeb:  begin
          lin.neb.comment:=catname+tab;
          end;
  end;
  while Assigned(row) do begin
    buf:=row.TextContent;
    // always ask to add j2000 coordinates
    if VOFields[i]='_RAJ2000' then lin.ra:=deg2rad*StrToFloatDef(buf,0);
    if VOFields[i]='_DEJ2000' then lin.dec:=deg2rad*StrToFloatDef(buf,0);
    case catversion of
    rtStar: begin
            lin.star.comment:=lin.star.comment+VOFields[i]+':'+buf+' '+TFieldData(VOFields.Objects[i]).units+tab;
            if (buf<>'')and(pos('meta.id',TFieldData(VOFields.Objects[i]).ucd)>0) then begin
              if (lin.star.id='')or(pos('meta.main',TFieldData(VOFields.Objects[i]).ucd)>0) then
                  if  pos('meta.id.part',TFieldData(VOFields.Objects[i]).ucd)>0 then begin
                      if lin.star.id='' then lin.star.id:=lin.star.id+buf
                                        else lin.star.id:=lin.star.id+'-'+buf;
                  end else lin.star.id:=buf;
            end;
            if pos('phot.mag',TFieldData(VOFields.Objects[i]).ucd)>0 then begin
              lin.star.valid[vsMagv]:=true;
              if (lin.star.magv=-99)or(pos('em.opt.V',TFieldData(VOFields.Objects[i]).ucd)>0) then begin
                 lin.options.flabel[lOffset+vsMagv]:=VOFields[i];
                 lin.star.magv:=StrToFloatDef(buf,99);
              end;
            end;
            if pos('pos.pm',TFieldData(VOFields.Objects[i]).ucd)>0 then begin
               if pos('pos.eq.ra',TFieldData(VOFields.Objects[i]).ucd)>0 then begin
                  lin.star.pmra:=StrToFloatDef(buf,0)*unitpmra;
               end
               else if pos('pos.eq.dec',TFieldData(VOFields.Objects[i]).ucd)>0 then begin
                 lin.star.pmdec:=StrToFloatDef(buf,0)*unitpmdec;
               end;
            end;
            end;
    rtNeb:  begin
            lin.neb.comment:=lin.neb.comment+VOFields[i]+':'+buf+' '+TFieldData(VOFields.Objects[i]).units+tab;
            if (buf<>'')and(pos('meta.id',TFieldData(VOFields.Objects[i]).ucd)>0) then begin
              if (lin.neb.id='')or(pos('meta.main',TFieldData(VOFields.Objects[i]).ucd)>0) then
                  if  pos('meta.id.part',TFieldData(VOFields.Objects[i]).ucd)>0 then begin
                      if lin.neb.id='' then lin.neb.id:=lin.neb.id+buf
                                        else lin.neb.id:=lin.neb.id+'-'+buf;
                  end else lin.neb.id:=buf;
            end;
            if pos('phot.mag',TFieldData(VOFields.Objects[i]).ucd)>0 then begin
               lin.options.flabel[lOffset+vnMag]:=VOFields[i];
               lin.neb.mag:=StrToFloatDef(buf,Defmag);;
               lin.neb.valid[vnMag]:=true;
            end;
            if pos('phys.angSize',TFieldData(VOFields.Objects[i]).ucd)>0 then begin
               lin.neb.dim1:=StrToFloatDef(buf,Defsize);
               lin.neb.valid[vnDim1]:=true;
            end;
            if pos('src.class',TFieldData(VOFields.Objects[i]).ucd)>0 then begin
               if trim(buf)='Gx'  then lin.neb.nebtype:=1
               else if trim(buf)='OC'  then lin.neb.nebtype:=2
               else if trim(buf)='Gb'  then lin.neb.nebtype:=3
               else if trim(buf)='Pl'  then lin.neb.nebtype:=4
               else if trim(buf)='Nb'  then lin.neb.nebtype:=5
               else if trim(buf)='C+N'  then lin.neb.nebtype:=6
               else if trim(buf)='*'  then lin.neb.nebtype:=7
               else if trim(buf)='D*'  then lin.neb.nebtype:=8
               else if trim(buf)='***'  then lin.neb.nebtype:=9
               else if trim(buf)='Ast'  then lin.neb.nebtype:=10
               else if trim(buf)='Kt'  then lin.neb.nebtype:=11
               else if trim(buf)='?'  then lin.neb.nebtype:=0
               else if trim(buf)=''  then lin.neb.nebtype:=0
               else if trim(buf)='-'  then lin.neb.nebtype:=-1
               else if trim(buf)='PD'  then lin.neb.nebtype:=-1;
            end;
            end;
    end;
    row:=row.NextSibling;
    inc(i);
  end;
  VoNode:=VoNode.NextSibling;
  ok:=true;
end;
if not ok then begin
   NextVOCat(ok);
   if ok then ReadVOCat(lin,ok);
end;
end;

Procedure NextVOCat( var ok : boolean);
begin
ok:=false;
inc(CurCat);
if CurCat<Ncat then begin
   catfile:=slash(VOCatpath)+VOcatlist[CurCat];
   deffile:=ChangeFileExt(catfile,'.config');
   if CurCat>0 then VODoc.Free;
   ok:=ReadVOHeader;
   if (not active)or(not ok) then NextVOCat(ok);
end;
end;

procedure CloseVOCat ;
var i: integer;
begin
VOcatlist.Free;
if VODocOK then VODoc.Free;
for i:=0 to VOFields.Count-1 do VOFields.Objects[i].Free;
VOFields.Free;
Ncat:=0;
CurCat:=0;
end;

end.
