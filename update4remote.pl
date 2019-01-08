#!/usr/bin/perl -w
use strict;
use LWP::Simple;
use Web::Scraper;
use URI;
use Net::FTP;

   my $url="http://v.ifeng.com/q/show/kaijuanbafenzhong/pro/list.shtml";
   my $i=5;
   while ($i>0)
   {
      ##�ҽ�Ŀ
      print "$i\n";
      my $href="";
      if($i==1){
      $href="/html/body/div[6]/div/div/div/h4/a";
      }else{
      $href="/html/body/div[6]/div/div/div[$i]/h4/a";};
      
      $i--;
      my $scraper = scraper {
         process $href,link => '@href';
      };
      my $result = $scraper->scrape( URI->new($url));
      last if not defined $result->{link};
      my $guid=$result->{link};
      $guid=~s/(http:\/\/v\.ifeng\.com\/.*\/\d{6}\/)(.*)(\.shtml$)/$2/;
      
      my $x1=substr($guid,-2,1);
      my $x2=substr($guid,-2);
      
      ##��ĿXML
      my $sxml="http://v.ifeng.com/video_info_new/".$x1."/".$x2."/".$guid.".xml";
      getstore($sxml,"$guid".".xml") or die("unknown url\n");
      open( FXML, "$guid".".xml") or die "Couldn't open $guid\.xml for reading: $!";
      read FXML,my $allxml, -s FXML;
      ##XML�ļ�����
      die "�Ҳ�����Ƶ��ַ!"if $allxml!~m/VideoPlayUrl.*?\//;       
      close FXML;

      ##��Ƶ��ַ
      my $mp4=$allxml;
      my $pname=$allxml;
      my $createdate=$allxml;
     
      $mp4=~s/.*VideoPlayUrl=\"(.*\.(mp4|flv)).*/$1/s;
      chomp $mp4;
      ##����
      $pname=~s/.*progName=\"(.*)\".*progUrl=.*/$1/s;
      chomp $pname;
      print "$pname\n";
      ##����
      $createdate=~s/.*CreateDate=\"(.*)\".*Keyword=.*/$1/s;
      chomp $createdate;
      print "$createdate\n";
      
      ##�ж��Ƿ���������Ŀ
      open REC,"rec.txt";
      read REC,my $rec, -s REC;
      die "�Ѿ�����" if $rec=~m/$guid/;
      close REC;
      
      ##������,��ӵ���¼
      open WRR ,">rec.txt";
      say  WRR  $guid."\,".$pname."\,".$mp4."\,".$createdate ;
      open WRR ,">>rec.txt";
      say  WRR  $rec;
      close WRR;
      
      
      ####����
      ##print "�������У�����\n";
      ##system("wget -c -q  $mp4");
      ##my $localmp4=$mp4;
      ##$localmp4=~s/.*\/(.*).*/$1/;
      ##
      ##my $localaac=$localmp4;
      ##$localaac=~s/(.*)\.mp4/$1/;

      
      ###ffmpeg����
      #print "�����У�����\n";
      ##system("ffmpeg -i $localmp4 -map 0:1 -ac 2 -ab 32000 $localmp3".".mp3");
      #system("ffmpeg -i $localmp4 -acodec copy $localaac\.aac");
      
      ##����XML__Remote
      print "����XML Remote\n";
      open RSS,"rss.xml";
      read RSS, my $headrss ,1280;
      read RSS, my $tailrss,-s RSS;
      $headrss=~s/\<pubDate\>.*\<\/pubDate\>/\<pubDate\>$createdate\<\/pubDate\>/;
      open RSS,">rss.xml";
      say RSS $headrss;
      open RSS,">>rss.xml";
      say RSS "<item><title>$pname</title><link>$mp4</link><description></description><pubDate>$createdate</pubDate><enclosure url=\"$mp4\"/><guid isPermaLink=\"false\">$mp4</guid><media:content url=\"$mp4\"/></item>";
      say RSS $tailrss;
      close RSS;
 
 
      ###����XML__Local
      #print "����XML_Local\n";
      #open RSS,"reader.xml";
      #read RSS,  $headrss ,1260;
      #$headrss=~s/\<pubDate\>.*\<\/pubDate\>/\<pubDate\>$createdate\<\/pubDate\>/;
      #open RSS,">reader.xml";
      #say RSS $headrss;
      #open RSS,">>reader.xml";
      #my $aac='http://192.168.1.220/podcast/';
      #$aac=$aac."$localaac.aac";
      #say RSS "<item><title>$pname</title><link>$aac</link><description></description><pubDate>$createdate</pubDate><enclosure url=\"$aac\"/><guid isPermaLink=\"false\">$aac</guid><media:content url=\"$aac\"/></item>";
      #say RSS '</channel></rss>';
      #close RSS;     
      
      
      ###�ϴ�aac
      #print "�ϴ�����aac,xml\n";
      #my $server='192.168.1.220';
      ##my $server='m6sting.3322.org';
      #my $user='lou';
      #my $pw='angel2000';
      #my $rdir='/disc0_1/web/podcast/';
      #my $ftp = Net::FTP->new($server);
      #$ftp->login($user,$pw) || die "Login failed";
      #$ftp->cwd($rdir)|| die print "$rdir doesn't seem to exist on $server. ";
      #$ftp->put(  "./$localaac.aac"  ,  "./$localaac.aac" ) || die "can not upload file";
      #$ftp->put(  "./reader.xml"  ,  "./reader.xml" ) || die "can not upload file";
      #$ftp->quit; 
                 
      unlink("$guid.xml");
      #unlink("$localaac.aac");
      #unlink("$localmp4.mp4");
   }

   ##print "�ϴ�Remote XML\n";
   ##my $server='hanoi.dreamhost.com';
   ##my $user='m6sting';
   ##my $pw='r7UWPZmp';
   ##my $rdir='/podcast/';
   ##
   ##my $ftp = Net::FTP->new($server);
   ##$ftp->login($user,$pw) || die "Login failed";
   ##$ftp->cwd($rdir)|| die print "$rdir doesn't seem to exist on $server. ";
   ##$ftp->put(  "./rss.xml"  ,  "./rss.xml" ) || die "can not upload file";
   ##$ftp->quit; 
   
   print "OK";
   
   
 
 