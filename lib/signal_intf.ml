module type Intf = sig
  type 'a base_signal
  type t
  include Utils.COMPARE with type t := t
  include Utils.PP with type t := t
  include Utils.RING with type t := t

  val comp_base : t base_signal -> t -> t
  val comp : t -> t -> t
end
