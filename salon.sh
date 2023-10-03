#! /bin/bash
# script to allow customers to book appointments
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

GET_SERVICES_ID() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    ID=$(echo $SERVICE_ID | sed 's/ //g')
    NAME=$(echo $SERVICE_NAME | sed 's/ //g')
    echo "$ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  
  case $SERVICE_ID_SELECTED in
    [1-5]) BOOKING_INFO ;;
        *) GET_SERVICES_ID "I could not find that service. What would you like today?" ;;
  esac
}

BOOKING_INFO() {
   # get customer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
 CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
# if customer doesn't exist
if [[ -z $CUSTOMER_NAME ]]
then
# get new customer name
echo -e "\nI don't have a record for that phone number, what's your name?"
read CUSTOMER_NAME
# insert new customer
INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi
# get service name
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')?"
read SERVICE_TIME
# get customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
# insert new appointment
INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
 if [[ $INSERT_APPOINTMENT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
  fi
}
GET_SERVICES_ID
