 program OtelYonetimSistemi;
uses Crt;

const
  MAX_ODA = 50;
  DOSYA_ADI = 'otel.dat';

type
  TarihStr = string[10];
  MusteriStr = string[30];
  
  OdaKayit = record
    musteri: MusteriStr;
    dolu: Boolean;
    girisTarih: TarihStr;
    odaTipi: Integer;
  end;
  
  OdaArray = array[1..MAX_ODA] of OdaKayit;

var
  odalar: OdaArray;
  odaUcret: array[1..3] of Integer;
  toplamKazanc: LongInt;
  secim: Integer;
  girilenSifre: string[20];

{ Tarih farkını hesaplayan fonksiyon }
function TarihFarkiHesapla(girisTarih, cikisTarih: TarihStr): Integer;
var
  gG, gA, gY, cG, cA, cY: Integer;
  gunSayisi: Integer;
begin
  { Giriş tarihi ayrıştırma }
  Val(Copy(girisTarih, 1, 2), gG, secim);
  Val(Copy(girisTarih, 4, 2), gA, secim);
  Val(Copy(girisTarih, 7, 4), gY, secim);
  
  { Çıkış tarihi ayrıştırma }
  Val(Copy(cikisTarih, 1, 2), cG, secim);
  Val(Copy(cikisTarih, 4, 2), cA, secim);
  Val(Copy(cikisTarih, 7, 4), cY, secim);
  
  { Basit gün farkı hesaplama }
  gunSayisi := (cY - gY) * 365 + (cA - gA) * 30 + (cG - gG);
  
  { En az 1 gün kalış }
  if gunSayisi < 1 then
    gunSayisi := 1;
    
  TarihFarkiHesapla := gunSayisi;
end;

{ Verileri dosyadan yükleyen prosedür }
procedure VeriYukle;
var
  i: Integer;
  tempInt: Integer;
  f: Text;
begin
  { Önce tüm odaları sıfırla }
  for i := 1 to MAX_ODA do
  begin
    odalar[i].musteri := '';
    odalar[i].dolu := False;
    odalar[i].girisTarih := '';
    odalar[i].odaTipi := 0;
  end;
  toplamKazanc := 0;
  
  { Dosyayı açmayı dene }
  {$I-}
  Assign(f, DOSYA_ADI);
  Reset(f);
  {$I+}
  
  { Dosya açma hatası kontrolü }
  if IOResult <> 0 then
    Exit;
  
  { Oda verilerini oku }
  i := 1;
  while (not EOF(f)) and (i <= MAX_ODA) do
  begin
    ReadLn(f, odalar[i].musteri);
    ReadLn(f, tempInt);
    odalar[i].dolu := tempInt <> 0;
    ReadLn(f, odalar[i].girisTarih);
    ReadLn(f, odalar[i].odaTipi);
    Inc(i);
  end;
  
  { Toplam kazancı oku }
  if not EOF(f) then
    ReadLn(f, toplamKazanc);
    
  Close(f);
end;

{ Verileri dosyaya kaydeden prosedür }
procedure VeriKaydet;
var
  i: Integer;
  tempInt: Integer;
  f: Text;
begin
  Assign(f, DOSYA_ADI);
  Rewrite(f);
  
  { Oda verilerini yaz }
  for i := 1 to MAX_ODA do
  begin
    WriteLn(f, odalar[i].musteri);
    if odalar[i].dolu then
      tempInt := 1
    else
      tempInt := 0;
    WriteLn(f, tempInt);
    WriteLn(f, odalar[i].girisTarih);
    WriteLn(f, odalar[i].odaTipi);
  end;
  
  { Toplam kazancı yaz }
  WriteLn(f, toplamKazanc);
  
  Close(f);
end;

{ Yeni müşteri kaydı yapan prosedür }
procedure MusteriKayit;
var
  adSoyad: MusteriStr;
  odaNo, tip: Integer;
begin
  ClrScr;
  WriteLn('=== YENI MUSTERI KAYDI ===');
  WriteLn;
  
  Write('Musteri Ad Soyad: ');
  ReadLn(adSoyad);
  
  repeat
    Write('Oda Numarasi (1-', MAX_ODA, '): ');
    ReadLn(odaNo);
    if (odaNo < 1) or (odaNo > MAX_ODA) then
      WriteLn('Hatali giris! 1-', MAX_ODA, ' arasinda bir deger girin.');
  until (odaNo >= 1) and (odaNo <= MAX_ODA);
  
  if odalar[odaNo].dolu then
  begin
    WriteLn('Bu oda zaten dolu!');
    Delay(2000);
    Exit;
  end;
  
  repeat
    WriteLn;
    WriteLn('Oda Tipi Seciniz:');
    WriteLn('1 - Standart (100 TL/gece)');
    WriteLn('2 - Deluxe (150 TL/gece)');
    WriteLn('3 - Suit (250 TL/gece)');
    Write('Seciminiz (1-3): ');
    ReadLn(tip);
    if (tip < 1) or (tip > 3) then
      WriteLn('Hatali giris! 1-3 arasinda bir deger girin.');
  until (tip >= 1) and (tip <= 3);
  
  odalar[odaNo].musteri := adSoyad;
  odalar[odaNo].odaTipi := tip;
  odalar[odaNo].dolu := False; { Kayıt yapıldı ama henüz giriş yapılmadı }
  
  WriteLn;
  WriteLn('Kayit basariyla alindi:');
  WriteLn('Oda No: ', odaNo);
  WriteLn('Musteri: ', adSoyad);
  WriteLn('Oda Tipi: ', tip);
  VeriKaydet;
  WriteLn;
  WriteLn('Devam etmek icin bir tusa basin...');
  ReadKey;
end;

{ Müşteri giriş işlemleri }
procedure MusteriGiris;
var
  odaNo: Integer;
  tarih: TarihStr;
begin
  ClrScr;
  WriteLn('=== MUSTERI GIRIS ISLEMI ===');
  WriteLn;
  
  repeat
    Write('Oda Numarasi (1-', MAX_ODA, '): ');
    ReadLn(odaNo);
    if (odaNo < 1) or (odaNo > MAX_ODA) then
      WriteLn('Hatali giris! 1-', MAX_ODA, ' arasinda bir deger girin.');
  until (odaNo >= 1) and (odaNo <= MAX_ODA);
  
  if odalar[odaNo].musteri = '' then
  begin
    WriteLn('Bu oda icin kayitli musteri bulunamadi!');
    Delay(2000);
    Exit;
  end;
  
  if odalar[odaNo].dolu then
  begin
    WriteLn('Bu oda zaten dolu!');
    Delay(2000);
    Exit;
  end;
  
  repeat
    Write('Giris Tarihi (GG/AA/YYYY): ');
    ReadLn(tarih);
    if Length(tarih) <> 10 then
      WriteLn('Hatali tarih format! GG/AA/YYYY seklinde girin.');
  until Length(tarih) = 10;
  
  odalar[odaNo].dolu := True;
  odalar[odaNo].girisTarih := tarih;
  
  WriteLn;
  WriteLn('Giris islemi basarili:');
  WriteLn('Oda No: ', odaNo);
  WriteLn('Musteri: ', odalar[odaNo].musteri);
  WriteLn('Giris Tarihi: ', tarih);
  VeriKaydet;
  WriteLn;
  WriteLn('Devam etmek icin bir tusa basin...');
  ReadKey;
end;

{ Müşteri çıkış işlemleri }
procedure MusteriCikis;
var
  odaNo: Integer;
  cikisTarih: TarihStr;
  gunSayisi: Integer;
  ucret: LongInt;
  onay: Char;
begin
  ClrScr;
  WriteLn('=== MUSTERI CIKIS ISLEMI ===');
  WriteLn;
  
  repeat
    Write('Oda Numarasi (1-', MAX_ODA, '): ');
    ReadLn(odaNo);
    if (odaNo < 1) or (odaNo > MAX_ODA) then
      WriteLn('Hatali giris! 1-', MAX_ODA, ' arasinda bir deger girin.');
  until (odaNo >= 1) and (odaNo <= MAX_ODA);
  
  if not odalar[odaNo].dolu then
  begin
    WriteLn('Bu oda zaten bos!');
    Delay(2000);
    Exit;
  end;
  
  repeat
    Write('Cikis Tarihi (GG/AA/YYYY): ');
    ReadLn(cikisTarih);
    if Length(cikisTarih) <> 10 then
      WriteLn('Hatali tarih format! GG/AA/YYYY seklinde girin.');
  until Length(cikisTarih) = 10;
  
  gunSayisi := TarihFarkiHesapla(odalar[odaNo].girisTarih, cikisTarih);
  ucret := gunSayisi * odaUcret[odalar[odaNo].odaTipi];
  
  WriteLn;
  WriteLn('Fatura Bilgileri:');
  WriteLn('Oda No: ', odaNo);
  WriteLn('Musteri: ', odalar[odaNo].musteri);
  WriteLn('Giris Tarihi: ', odalar[odaNo].girisTarih);
  WriteLn('Cikis Tarihi: ', cikisTarih);
  WriteLn('Kalinan Gun: ', gunSayisi);
  WriteLn('Oda Tipi: ', odalar[odaNo].odaTipi);
  WriteLn('Birim Fiyat: ', odaUcret[odalar[odaNo].odaTipi], ' TL/gece');
  WriteLn('Toplam Ucret: ', ucret, ' TL');
  WriteLn;
  
  repeat
    Write('Cikis islemini onayliyor musunuz? (E/H): ');
    ReadLn(onay);
    onay := UpCase(onay);
    if (onay <> 'E') and (onay <> 'H') then
      WriteLn('Hatali giris! E veya H girin.');
  until (onay = 'E') or (onay = 'H');
  
  if onay = 'E' then
  begin
    odalar[odaNo].dolu := False;
    odalar[odaNo].musteri := '';
    odalar[odaNo].girisTarih := '';
    odalar[odaNo].odaTipi := 0;
    toplamKazanc := toplamKazanc + ucret;
    
    WriteLn;
    WriteLn('Cikis islemi tamamlandi. Oda bosaltildi.');
    VeriKaydet;
  end
  else
    WriteLn('Cikis islemi iptal edildi.');
  
  WriteLn;
  WriteLn('Devam etmek icin bir tusa basin...');
  ReadKey;
end;

{ Oda durumlarını görüntüleyen prosedür }
procedure OdaDurumu;
var
  i: Integer;
  durumStr, tipStr: string[15];
begin
  ClrScr;
  WriteLn('=== ODA DURUMU ===');
  WriteLn;
  WriteLn('No | Durum     | Tip        | Musteri');
  WriteLn('-------------------------------------------');
  
  for i := 1 to MAX_ODA do
  begin
    { Oda durumu }
    if odalar[i].dolu then
      durumStr := 'Dolu      '
    else if odalar[i].musteri <> '' then
      durumStr := 'Rezerve   '
    else
      durumStr := 'Bos       ';
    
    { Oda tipi }
    case odalar[i].odaTipi of
      1: tipStr := 'Standart  ';
      2: tipStr := 'Deluxe    ';
      3: tipStr := 'Suit      ';
      else tipStr := 'Belirsiz  ';
    end;
    
    WriteLn(i:2, ' | ', durumStr, ' | ', tipStr, ' | ', odalar[i].musteri);
  end;
  
  WriteLn;
  WriteLn('Toplam Kazanc: ', toplamKazanc, ' TL');
  WriteLn;
  WriteLn('Devam etmek icin bir tusa basin...');
  ReadKey;
end;

{ Oda tipine göre filtreleme }
procedure OdaFiltrele;
var
  tip, i: Integer;
  durumStr, tipStr: string[10];
  bulunan: Boolean;
begin
  ClrScr;
  WriteLn('=== ODA TIPINE GORE FILTRELEME ===');
  WriteLn;
  
  repeat
    WriteLn('Oda Tipi Seciniz:');
    WriteLn('1 - Standart');
    WriteLn('2 - Deluxe');
    WriteLn('3 - Suit');
    Write('Seciminiz (1-3): ');
    ReadLn(tip);
    if (tip < 1) or (tip > 3) then
      WriteLn('Hatali giris! 1-3 arasinda bir deger girin.');
  until (tip >= 1) and (tip <= 3);
  
  ClrScr;
  case tip of
    1: WriteLn('=== STANDART ODALAR ===');
    2: WriteLn('=== DELUXE ODALAR ===');
    3: WriteLn('=== SUIT ODALAR ===');
  end;
  WriteLn;
  
  bulunan := False;
  WriteLn('No | Durum    | Musteri');
  WriteLn('--------------------------');
  
  for i := 1 to MAX_ODA do
  begin
    if odalar[i].odaTipi = tip then
    begin
      bulunan := True;
      if odalar[i].dolu then
        durumStr := 'Dolu   '
      else if odalar[i].musteri <> '' then
        durumStr := 'Rezerve'
      else
        durumStr := 'Bos    ';
      
      WriteLn(i:2, ' | ', durumStr, ' | ', odalar[i].musteri);
    end;
  end;
  
  if not bulunan then
    WriteLn('Bu tipte kayitli oda bulunamadi.');
  
  WriteLn;
  WriteLn('Devam etmek icin bir tusa basin...');
  ReadKey;
end;

{ Günlük kazanç raporu }
procedure GunlukKazancRaporu;
begin
  ClrScr;
  WriteLn('=== GUNLUK KAZANC RAPORU ===');
  WriteLn;
  WriteLn('Toplam Kazanc: ', toplamKazanc, ' TL');
  WriteLn;
  WriteLn('Devam etmek icin bir tusa basin...');
  ReadKey;
end;

{ Ana menüyü gösteren prosedür }
procedure MenuGoster;
begin
  repeat
    ClrScr;
    WriteLn('=== OTEL YONETIM SISTEMI ===');
    WriteLn;
    WriteLn('1. Yeni Musteri Kaydi');
    WriteLn('2. Musteri Giris Islemleri');
    WriteLn('3. Musteri Cikis Islemleri');
    WriteLn('4. Oda Durumunu Goruntule');
    WriteLn('5. Oda Tipine Gore Filtrele');
    WriteLn('6. Gunluk Kazanc Raporu');
    WriteLn('7. Cikis');
    WriteLn;
    Write('Seciminiz (1-7): ');
    ReadLn(secim);
    
    case secim of
      1: MusteriKayit;
      2: MusteriGiris;
      3: MusteriCikis;
      4: OdaDurumu;
      5: OdaFiltrele;
      6: GunlukKazancRaporu;
      7: begin
           VeriKaydet;
           ClrScr;
           WriteLn('Program sonlandiriliyor...');
           Delay(1000);
         end;
      else begin
        WriteLn('Gecersiz secim! Tekrar deneyin.');
        Delay(2000);
      end;
    end;
  until secim = 7;
end;

{ Ana program }
begin
  { Oda ücretleri tanımlanıyor }
  odaUcret[1] := 100;  { Standart }
  odaUcret[2] := 150;  { Deluxe }
  odaUcret[3] := 250;  { Suit }
  
  { Şifre kontrolü }
  ClrScr;
  WriteLn('=== OTEL YONETIM SISTEMI ===');
  WriteLn;
  Write('Sifreyi giriniz: ');
  ReadLn(girilenSifre);
  
  if girilenSifre <> 'otel123' then
  begin
    WriteLn;
    WriteLn('Yanlis sifre! Program kapatiliyor.');
    Delay(2000);
    Halt;
  end;
  
  { Verileri yükle ve menüyü göster }
  VeriYukle;
  MenuGoster;
end.
