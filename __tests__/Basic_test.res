open Ava

test("basic string equality", t => {
  t->Assert.is("hello", "hello")
})

test("basic number equality", t => {
  t->Assert.is(42, 42)
})

test("array length", t => {
  let arr = [1, 2, 3]
  t->Assert.is(Array.length(arr), 3)
})

asyncTest("promise resolution", t => {
  Promise.resolve("success")->Promise.thenResolve(result => {
    t->Assert.is(result, "success")
  })
})
