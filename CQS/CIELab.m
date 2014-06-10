function [Lab] = CIELab(XYZTCS, XYZw)
  Lab = zeros(15,3);
  for i=1:15
      Lab(i,1) = 116 * nthroot(XYZTCS(i,2)/XYZw(2) ,3) - 16;
      Lab(i,2) = 500*( nthroot( XYZTCS(i,1)/XYZw(1),3) - nthroot( XYZTCS(i,2)/XYZw(2),3) );
      Lab(i,3) = 200*( nthroot( XYZTCS(i,2)/XYZw(2),3) -nthroot( XYZTCS(i,3)/XYZw(3),3) );
  end
  