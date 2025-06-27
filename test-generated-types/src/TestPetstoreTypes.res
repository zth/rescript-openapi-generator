// Test file using the generated Petstore types
open GeneratedPetstoreTypes

// Test enum usage
let availableStatus = Available
let placedOrderStatus = Placed

// Test creating objects with required fields
let testPet: pet = {
  name: "Buddy",
  photoUrls: ["photo1.jpg", "photo2.jpg"],
}

// Test creating objects with optional fields
let fullPet: pet = {
  name: "Max",
  photoUrls: ["photo.jpg"],
  id: 123,
  status: Available,
  category: {
    id: 1,
    name: "Dogs",
  },
  tags: ["friendly", "playful"],
}

// Test using the problematic 'type' field (now type_)
let apiResp: apiResponse = {
  code: 200,
  message: "Success",
  type_: "application/json",
}

// Test creating an order
let testOrder: order = {
  id: 1,
  petId: 123,
  quantity: 2,
  status: Approved,
  complete: true,
}

// Test pattern matching on enums
let getStatusMessage = (status: petStatus) => {
  switch status {
  | Available => "Pet is available for adoption"
  | Pending => "Pet adoption is pending"
  | Sold => "Pet has been adopted"
  }
}

let getOrderStatusMessage = (status: orderStatus) => {
  switch status {
  | Placed => "Order has been placed"
  | Approved => "Order has been approved"  
  | Delivered => "Order has been delivered"
  }
}

// Demo function
let testGeneratedTypes = () => {
  Console.log("✅ Generated Petstore types work correctly!")
  Console.log(`Pet: ${testPet.name}`)
  Console.log(`Full pet status: ${getStatusMessage(Available)}`)
  Console.log(`Order status: ${getOrderStatusMessage(Approved)}`)
  
  // Access optional field safely
  switch apiResp.type_ {
  | Some(contentType) => Console.log(`API response type: ${contentType}`)
  | None => Console.log("No content type specified")
  }
}

// Run the test
testGeneratedTypes() 