<?php
session_start();
class hitCounter
{
  private $numHits; //total session visits to home page
  private $hits_file; //filename containing the total number of hits to home page
  private $logfile; //filename containing the data for visits to home page

  /***********************************************************************
  Class Constructor
  ***********************************************************************/
  function __construct()
  {
    $this->numHits = 0;
    $this->hits_file = "hit_counts.txt";
    $this->logfile = "visits.txt";
  }

  /***********************************************************************
  Class Methods
  ***********************************************************************/
  public function incrCounter()
  {
    if(file_exists($this->hits_file))
    {
      $fr = fopen($this->hits_file,'r');

      $hitsFromFile = fgets($fr);
      if($this->isPosInt($totHits+0)) $this->numHits = $hitsFromFile+1; { //increment the total hits by 1
        fclose($fr);
      }

      $fw = fopen($this->hits_file,'w');
      fwrite($fw,$this->numHits); //save the updated total hits to a text file
      fclose($fw);
    }

    //update the counter logfile
    if(file_exists($this->logfile)) {
      if(isset($_SESSION['visitorUrl'])) {//get the referer to home page
        $referer = $_SESSION['visitorUrl'];
      }
      else {
        $referer = '';
      }

      $str = "\\r\
      "."Remote addr\	".$_SERVER['REMOTE_ADDR']."\\r\
      ".
      "Server addr\	".$_SERVER['SERVER_ADDR']."\\r\
      ".
      "User agent\	".$_SERVER['HTTP_USER_AGENT']."\\r\
      ".
      "Referer:\	".$referer."\\r\
      ".
      "Total visits:\	".$this->numHits."\\r\
      ".
      date('j M Y g:i a')."\\r\
      ";
      $fw = fopen($this->logfile,'a+'); //open the logfile
      fwrite($fw,$str); //write the log data for this visit to file
      fclose($fw);
    }
  }

  public function getLogRecords() {
    $recordsA = array();

    if(file_exists($this->logfile)) {
      $recordsA = file($this->logfile); //read the records from the logfile into an array
    } else {
      $recordsA[0] = '<p style="text-align: center; color: rgb(255,0,0); font-size: 14pt">Logfile does not exist.</p>';
    }
    return $recordsA;
  }

  /***********************************************************************
  Helper Functions
  ***********************************************************************/
  private function isPosInt($n)
  {
    if (preg_match("/[^0-^9]+/",$n) > 0)
    return false;
    else
    return true;
  }
}
?>

