type author =
  { name: string
  ; email: string
  }

module type S = sig
  val author : author
end
