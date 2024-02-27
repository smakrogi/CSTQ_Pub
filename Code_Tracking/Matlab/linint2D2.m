function S=linint2D2(f,g,T)
% Original code by Bilge Karacali.
% Edits: Sokratis Makrogiannis, February 2006 (makrogis@uphs.upenn.edu)

[r,c]=size(T);
S=zeros(size(f));

x=1:c;
y=1:r;
[X,Y]=meshgrid(x,y);

ff=f(:);
gg=g(:);
XX=X(:);
YY=Y(:);

I=find((ff>=1)&(ff<=c)&(gg>=1)&(gg<=r));

flff=floor(ff(I));
clff=ceil(ff(I));
flgg=floor(gg(I));
clgg=ceil(gg(I));

T11=T(flgg+r*(flff-1));
T12=T(flgg+r*(clff-1));
T21=T(clgg+r*(flff-1));
T22=T(clgg+r*(clff-1));

lambdax=ff(I)-flff;
T1=lambdax.*T12+(1-lambdax).*T11;
T2=lambdax.*T22+(1-lambdax).*T21;

lambday=gg(I)-flgg;
S(I)=lambday.*T2+(1-lambday).*T1;
