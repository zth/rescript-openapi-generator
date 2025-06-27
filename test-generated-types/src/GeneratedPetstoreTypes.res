// Generated ReScript types from OpenAPI specification

type orderStatus = | @as("placed") Placed | @as("approved") Approved | @as("delivered") Delivered

type petStatus = | @as("available") Available | @as("pending") Pending | @as("sold") Sold

type order = {
  complete?: bool,
  id?: int,
  petId?: int,
  quantity?: int,
  shipDate?: string,
  status?: orderStatus,
}

type category = {
  id?: int,
  name?: string,
}

type user = {
  email?: string,
  firstName?: string,
  id?: int,
  lastName?: string,
  password?: string,
  phone?: string,
  userStatus?: int,
  username?: string,
}

type tag = {
  id?: int,
  name?: string,
}

type pet = {
  name: string,
  photoUrls: array<string>,
  category?: category,
  id?: int,
  status?: petStatus,
  tags?: array<string>,
}

type apiResponse = {
  code?: int,
  message?: string,
  @as("type") type_?: string,
}
