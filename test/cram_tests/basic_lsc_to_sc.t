Create a test file:
  $ cat >ex1.lsc <<EOF
  > let pi = 3.14159265358979312 in
  > let sin_osc = fun freq phase ->
  >   sin << (2. * pi * freq * t + phase)
  > in
  > let s1 = sin_osc 440. 0. in
  > let s2 = sin_osc 1. 0. in
  > s2 * s1
  > EOF
Convert to SuperCollider:
  $ compsig -i lsc -o sc < ex1.lsc
  s.waitForBoot({{SinOsc.ar(freq: 1.0, phase: 0.0) * SinOsc.ar(freq: 440.0, phase: 0.0)}.play;});
