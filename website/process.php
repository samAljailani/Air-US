<?php
$mysqli = new mysqli("localhost", "root", "", "flights");
if($mysqli->connect_error) {
  exit('<h1>Could not connect to database<h1>');
}
$sql = "";
switch($_GET['q']){
    case "Flights":
        $sql =  "SELECT  carrier_id, flight_id, date, arr_airport_id, dept_time, arr_time, dept_airport_id FROM flights natural join planes where date = ? and arr_airport_id = ? order by dept_time";
        $stmt = $mysqli->prepare($sql);
        printFlights($stmt);
        $stmt->close();
        break;
    case "Employees":
        $sql = "Select * from employees_on_flight natural join employees where employees_on_flight.flight_id = ?";
        $stmt = $mysqli->prepare($sql);
        printEmployees($stmt);
        break;
    case "Passengers_On_Flight":
        
        $sql =  "SELECT  * FROM transactions where flight_id = ?";
        $stmt = $mysqli->prepare($sql);
        printPassengersOnFlight($stmt);

        break;
    case "Airlines":
        $sql =  "SELECT * From Airlines";
        $stmt = $mysqli->prepare($sql);
        $stmt->prepare($sql);
        printAirlines($stmt);
        break;
    case "PassengerInfo"://pop up page when clicking on book button
        ProcessPassengerInfo($mysqli);
    
     
        break;
    case "FlightsOnDate":
       
        $sql ="select count(*) as count, arr_airport_id, name from flights join airports on arr_airport_id = airport_id where date = ? group by arr_airport_id order by count desc, name;";
        $stmt = $mysqli->prepare($sql);
        $stmt->prepare($sql);
        PrintFlightOnDate($stmt);
        break;
    case "Planes":
        $sql = "select * from planes;";
        $stmt = $mysqli->prepare($sql);
        $stmt->prepare($sql);
        PrintPlanes($stmt);
        break;
    case "AirPorts":
        
        $sql = "select * from airports;";
        $stmt = $mysqli->prepare($sql);
        PrintAirports($stmt);
        break;
    case "Transactions":
        
            $sql = "select * from transactions;";
            $stmt = $mysqli->prepare($sql);
            PrintTransactoins($stmt);
        break;
    }
/////////////////////////////////////////////////////
function ProcessPassengerInfo($mysqli){
    $sql = "select exists(select * from passengers where passenger_email = ?) as exist;";
    $stmt = $mysqli->prepare($sql);
    $stmt->bind_param('s', $_GET['Email']);
    $stmt->execute();
    $result = $stmt->get_result();
    $table = $result->fetch_all(MYSQLI_ASSOC);//entire table
    $exists;
    foreach($table as $row){
        $exists = $row['exist'];
    }$stmt->close();
    if(!$exists){//insert new passenger into passenger table as well as transaction
        $sql ="Insert into Passengers( passenger_email,first_name, last_name, address, city, state, zip_code, country, credit_card_num, card_exp_date, card_sec_num)";
        $sql = $sql . " values(?,?,?,?,?,?,?,?,?,?,? );";
        $stmt = $mysqli->prepare($sql);
        InsertPassanger($stmt);

        $stmt->close();
        $sql ="Insert into Transactions( passenger_email, flight_id, class, baggage) values(?,?,?, ?);";
        $stmt = $mysqli->prepare($sql);

        $stmt->bind_param('ssss', $_GET['Email'], $_GET['flight_id'], $_GET['Class'], $_GET['baggage']);
        $stmt->execute();
    }else{//only insert new transaction
        $sql ="Insert into Transactions( passenger_email, flight_id, class, baggage) values(?,?,?, ?);";
        $stmt = $mysqli->prepare($sql);
        
        $stmt->bind_param('ssss', $_GET['Email'], $_GET['flight_id'], $_GET['Class'], $_GET['baggage']);
        $stmt->execute();
    }
          
}
/////////////////////////////////////////////////////
function PrintTransactoins($stmt){
    $stmt->execute();
    $result = $stmt->get_result();
    $table = $result->fetch_all(MYSQLI_ASSOC);//entire table
    echo '<table id="Planes_table">';
    echo '<tr><th>Trancation</th><th>Flight ID</th><th>Passenger Email</th><th>Passenger Class/th></tr>';
    foreach($table as $row){
        
      echo '<tr><td>'.$row['tx_id'].'</td><td>'.$row['flight_id'].'</td><td>'.$row['passenger_email'].'</td><td>'.$row['class'].'</td></tr>';
    }
    echo '</table>';
}
/////////////////////////////////////////////////////
function PrintAirports($stmt){
    $stmt->execute();
    $result = $stmt->get_result();
    $table = $result->fetch_all(MYSQLI_ASSOC);//entire table
    echo '<table id="Planes_table">';
    echo '<tr><th>Airport ID</th><th>Name</th><th>Time Zone</th><th>longtitude</th><th>latitude</th></tr>';
    foreach($table as $row){
        
      echo '<tr><td>'.$row['airport_id'].'</td><td>'.$row['name'].'</td><td>'.$row['timezone'].'</td><td>'.$row['longitude'].'</td><td>'.$row['latitude'].'</td></tr>';
    }
    echo '</table>';
}
/////////////////////////////////////////////////////
function PrintPlanes($stmt){
    $stmt->execute();
    $result = $stmt->get_result();
    $table = $result->fetch_all(MYSQLI_ASSOC);//entire table
    echo '<table id="Planes_table">';
    echo '<tr><th>Plane_id</th><th>Carrier</th><th>type</th><th>manufacturer</th><th>model</th><th>Economy Seats</th><th>Premium Economy Seats</th><th>Business Seats</th><th>First Class seats</th></tr>';
    foreach($table as $row){
        
      echo '<tr><td>'.$row['plane_id'].'</td><td>'.$row['carrier_id'].'</td><td>'.$row['type'].'</td><td>'.$row['manufacturer'].'</td><td>'.$row['model'].'</td><td>'.$row['economy'].'</td><td>'.$row['premium_economy'].'</td><td>'.$row['business'].'</td><td>'.$row['first_class'].'</td></tr>';
    }
    echo '</table>';
}
/////////////////////////////////////////////////////
function PrintFlightOnDate($stmt){
    $stmt->bind_param("s", $_GET["Date"]);
    $stmt->execute();
    $result = $stmt->get_result();
    $table = $result->fetch_all(MYSQLI_ASSOC);//entire table
    echo '<table id="FlightsOnDate_table">';
    echo '<tr><th>Airport ID</th><th>Airoprt Name</th><th>Number of Flights</th></tr>';
    foreach($table as $row){
        
      echo '<tr><td>'.$row['arr_airport_id'].'</td><td>'.$row['name'].'</td><td>'.$row['count'].'</td></tr>';
    }
}
/////////////////////////////////////////////////////
function InsertPassanger($stmt){
    $stmt->bind_param("ssssssssisi", $_GET["Email"],$_GET["FirstName"], $_GET['LastName'], $_GET["Address"], $_GET["City"], $_GET["State"],$_GET["Zip"],$_GET["Country"], $_GET["CardNum"], $_GET["Expr"],$_GET["CVV"]);
    $stmt->execute();
}
//////////////////////////////////////////////////////
function printFlights($stmt){
$stmt->bind_param("ss", $_GET["Date"], $_GET['FlightDest']);
$stmt->execute();
$result = $stmt->get_result();
$table = $result->fetch_all(MYSQLI_ASSOC);//entire table

foreach($table as $row){
    $price = rand() % 800 + 100;
    $airline = 'DL';
    $duration= '1';
    echo '<div class="Flight_Data"><div id="Upper_Section"><div id="Airline"><b>Airline:',$row['carrier_id'], '</b></div><div id="Flight_ID"><b>Flight ID:',$row['flight_id'],'</b></div></div><div id="Middle_Section"><div id="Dearture"><b>Departing from:',$row['dept_airport_id'],' </b></div> <div if="Flight_Icon"><img src="Flight_Icon.png" style="width:300px; height:auto;" /></div><div id="Destination"><b>Destination:',$row['arr_airport_id'],'</b></div></div><div id="Flight_Time"><div id="Departing_Time"><b>',$row['dept_time'],'</b></div><div id="Duration"><b></b></div><div id="Arrival_Time"><b>',$row['arr_time'],'</b></div></div><div id="Lower_Section" style="width:100%; display:flex; justify-content:center;"><div><button id ="Purchase" onclick=\'document.location="./PassengerInfo.html"\'><b>Book</b></button></div></div></div>';
}
//7JQ15P7LDU9DALLMO7YP

}
//////////////////////////////////////////////////////
function printEmployees($stmt){
$stmt->bind_param('s', $_GET['flight_id']);
$stmt->execute();
$result = $stmt->get_result();
$table = $result->fetch_all(MYSQLI_ASSOC);

echo '<table id="Emplyees_table">';
echo '<tr><th>First Name</th><th>Last Name</th><th>ID</th><th>Flight ID</th><th>Title</th><th>Salary</th><th>Start Date</th></tr>';
foreach($table as $row){
    echo '<tr><td>'.$row['first_name'].'</td><td>'.$row['last_name'].'</td><td>'.$row['employee_id'].'</td><td>'.$row['flight_id'].'</td><td>'.$row['title'].'</td><td>'.$row['salary'].'</td><td>'.$row['start_date'].'</td></tr>';
}

echo '</table>';
}
///////////////////////////////////////////////////////
function printAirlines($stmt){
$stmt->execute();
$result = $stmt->get_result();

$table = $result->fetch_all(MYSQLI_ASSOC);
echo '<table id="Airline_table">';
echo '<tr><th>Airline ID</th><th>Airline Name</th></tr>';
foreach($table as $row){
    echo '<tr><td>'.$row['carrier_id'].'</td><td>'.$row['name'].'</td></tr>';
}
echo '</table>';
}
//////////////////////////////////////////////////////
function printPassengersOnFlight($stmt){
$stmt->bind_param('s', $_GET['flight_id']);
$stmt->execute();
$result = $stmt->get_result();
$table = $result->fetch_all(MYSQLI_ASSOC);

echo '<table id="Passengers_On_Flight_table">';
echo '<tr><th>Flight ID</th><th>Passenger Email</th><th>Class</th><th>Baggage</th><tr>';

foreach($table as $row){
    echo '<tr><td>'.$row['flight_id'].'</td><td>'.$row['passenger_email'].'</td><td>'.$row['class'].'</td><td>'.$row['baggage'].'</td></tr>';
}

echo '</table>';
}
///////////////////////////////////////////////////////
?>