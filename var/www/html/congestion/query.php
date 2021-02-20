<?php
  require_once 'connection.php'; // подключаем скрипт

  // подключаемся к серверу
  $link = mysqli_connect($host, $user, $password, $database)
      or die("Ошибка " . mysqli_error($link));
  mysqli_set_charset($link, "utf8");

// выполняем операции с базой данных
  date_default_timezone_set('Asia/Yakutsk');
  echo "<table><tr><th>Таймер</th><th>Время начала разговора</th><th>Номер</th><th>Имя</th><th>Канал</th></tr>";
  $query = "SELECT bridgeuniqueid,datetime,FROM_UNIXTIME(datetime),name,callerid,channel,color FROM current_congestion  ORDER BY bridgeuniqueid";
  $result = mysqli_query($link, $query) or die("Ошибка " . mysqli_error($link));
  if($result)
  {
       $row = mysqli_fetch_row($result);
       $bridgequniqueid = 0;
       $color = "#e8edff";
       $rows = mysqli_num_rows($result); // количество полученных строк
       for ($i = 0 ; $i < $rows ; ++$i)
         {
          if (($bridgequniqueid<>$row[0]) && ($row[0] <> 1000))
            {
               $bridgequniqueid = $row[0];
               if ($color == "#e8edff") 
                  {$color = "#ccddff";}
               else {$color = "#e8edff";}
            }
          else if ($row[0]==1000)
          {
                 $color = "#ffa6a6";
          }
          echo "<tr style = \"background: $color\">";
          $timestamp = time() - $row[1];
          echo "<td class=\"ext-view-m ext-view-off\">$row[0]</td>";
          echo "<td>".date('i:s',$timestamp)."</td>";
          for ($j = 2 ; $j < 6 ; ++$j) echo "<td>$row[$j]</td>";
          echo "</tr>";
          $row = mysqli_fetch_row($result);
         }
      }
    echo "</table>";
    //echo "<span onclick=\"return toggleView(this, 'data-table', 'td')\" style=\"cursor: pointer;\"> Turn detailed view on </span>";
    // очищаем результат
    mysqli_free_result($result);


// закрываем подключение
mysqli_close($link);
?>
