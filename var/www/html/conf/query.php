<?php
  require_once 'connection.php'; // подключаем скрипт
 
  // подключаемся к серверу
  $link = mysqli_connect($host, $user, $password, $database) 
      or die("Ошибка " . mysqli_error($link));
  mysqli_set_charset($link, "utf8");

// выполняем операции с базой данных
  $query ="SELECT callerid,name,datetime,channel,talking FROM current_conf";
  $result = mysqli_query($link, $query) or die("Ошибка " . mysqli_error($link)); 
  if($result)
  {
    $rows = mysqli_num_rows($result); // количество полученных строк
    $color = "#e8edff";
    echo "<table><tr><th>Имя</th><th>Номер</th><th>Время входа</th><th>Канал</th><th>Статус</th></tr>";
    for ($i = 0 ; $i < $rows ; ++$i)
    {
        $row = mysqli_fetch_row($result);
        echo "<tr style = \"background: $color\">";
            for ($j = 0 ; $j < 5 ; ++$j) echo "<td>$row[$j]</td>";
        echo "</tr>";
        if ($color == "#e8edff")
          {$color = "#ccddff";}
        else
          {$color = "#e8edff";}
    }
    echo "</table>";
     
    // очищаем результат
    mysqli_free_result($result);
  
 }
 
// закрываем подключение
mysqli_close($link);
?> 
