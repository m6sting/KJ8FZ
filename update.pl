#!/usr/bin/perl -w
use strict;
use LWP::Simple;
use Web::Scraper;
use URI;
use Net::FTP;

   my $url="http://v.ifeng.com/q/show/kaijuanbafenzhong/pro/list_40.shtml";
   my $i=33;
   while ($i>0)
   {
      ##找节目
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
      ##print "$guid";
      
      my $x1=substr($guid,-2,1);
      my $x2=substr($guid,-2);
      
      ##节目XML
      my $sxml="http://v.ifeng.com/video_info_new/".$x1."/".$x2."/".$guid.".xml";
      getstore($sxml,"$guid".".xml") or die("unknown url\n");
      open( FXML, "$guid".".xml") or die "Couldn't open $guid\.xml for reading: $!";
      read FXML,my $allxml, -s FXML;
      ##XML文件错误
      die "找不到视频地址!"if $allxml!~m/VideoPlayUrl.*?\//;       
      close FXML;

      ##视频地址
      my $mp4=$allxml;
      my $html=$allxml;
      my $pname=$allxml;
      my $createdate=$allxml;
     
      $mp4=~s/.*VideoPlayUrl=\"(.*\.(mp4|flv)).*/$1/s;
      chomp $mp4;
      $mp4=~s/video\.ifeng\.com/video16\.ifeng\.com/s;
      
      $html=~s/.*PlayerUrl=\"(.*?\.shtml).*/$1/s;
      chomp $html;
      ##名字
      $pname=~s/.*progName=\"(.*)\".*progUrl=.*/$1/s;
      chomp $pname;
      print "$pname\n";
      ##日期
      $createdate=~s/.*CreateDate=\"(.*)\".*Keyword=.*/$1/s;
      chomp $createdate;
      print "$createdate\n";
      
      ##判断是否存在这个节目
      open REC,"rec.txt";
      read REC,my $rec, -s REC;
      die "已经存在" if $rec=~m/$guid/;
      close REC;
      
      ##不存在,添加到记录
      open WRR ,">rec.txt";
      say  WRR  $guid."\,".$pname."\,".$mp4."\,".$createdate ;
      open WRR ,">>rec.txt";
      say  WRR  $rec;
      close WRR;
      
      

      
      ##插入XML__Remote
      print "插入XML Remote\n";
      open RSS,"rss.xml";
      read RSS, my $headrss ,1280;
      read RSS, my $tailrss,-s RSS;
      $headrss=~s/\<pubDate\>.*\<\/pubDate\>/\<pubDate\>$createdate\<\/pubDate\>/;
      open RSS,">rss.xml";
      say RSS $headrss;
      open RSS,">>rss.xml";
      say RSS "<item><title>$pname</title><link>$html</link><description></description><pubDate>$createdate</pubDate><enclosure url=\"$mp4\"/><guid isPermaLink=\"false\">$mp4</guid><media:content url=\"$mp4\"/></item>";
      say RSS $tailrss;
      close RSS;
 
 

                 
      #unlink("$guid.xml");
      #unlink("$localaac.aac");
      #unlink("$localmp4.mp4");
   }


   
   print "OK";
   
   
 
 