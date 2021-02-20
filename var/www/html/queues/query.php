<?php
  require_once 'connection.php'; // подключаем скрипт

  // подключаемся к серверу
  $link = mysqli_connect($host, $user, $password, $database)
      or die("Ошибка " . mysqli_error($link));
  mysqli_set_charset($link, "utf8");

// выполняем операции с базой данных
  date_default_timezone_set('Asia/Yakutsk');
  echo "<table><tr><th>Таймер</th><th>Время</th><th>Событие</th><th>Номер</th><th>Имя</th><th>Интерфейс</th><th>Имя оператора</th><th>Время ожидания</th><th>Время вызова оператора</th><th>Время разговора</th><th>Статус звонка</th><th>Номер оператора</th><th>Имя оператора</th></tr>";
  $query = "SELECT UNIX_TIMESTAMP(dt),dt, EventDescription, CallerIDNum, CallerIDName, Interface, MemberName, HoldTime, RingTime, TalkTime, Status, DestCallerIDNum, DestCallerIDName, LinkedId FROM asterisk.queuestatus WHERE Queue = 'support' ORDER BY dt DESC LIMIT 100";
  $result = mysqli_query($link, $query) or die("Ошибка " . mysqli_error($link));
  if($result)
  {
       $row = mysqli_fetch_row($result);
       $linkedid = $row[13];;
       $color = "#e8edff";
       $rows = mysqli_num_rows($result); // количество полученных строк
       for ($i = 0 ; $i < $rows ; ++$i)
       { 
          if ($linkedid<>$row[13])
          {
             $linkedid = $row[13];
             if ($color == "#e8edff")
              {$color = "#ccddff";}
             else 
             {$color = "#e8edff";}
          }
          echo "<tr style = \"background: $color\">";
          $timestamp = time() - $row[0];
          echo "<td>".date('i:s',$timestamp)."</td>";
          echo "<td>$row[1]</td>";
          for ($j = 2 ; $j < 13 ; ++$j) echo "<td>$row[$j]</td>";
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
