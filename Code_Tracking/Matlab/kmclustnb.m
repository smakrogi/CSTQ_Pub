clear all
clc

le=40;
data=random('Normal',0,1,le,2);
data=[data; random('Normal',2,1,le,2)];
idsR(1:le,1)=1;
idsR(le+1:2*le)=2;

distM=squareform(pdist(data));
[ids]=kmeans(data,2);
%[ids2]=spectralClust(1,data,2,1);


disp(sprintf('number index for kmeans %d', number(2,distM,ids)));
%disp(sprintf('number index for clusterdata %d', number(2,distM,ids2)));

%% Graphs
subplot(3,1,1);scatter(data(:,1),data(:,2),10,idsR,'filled');title('Original clusters');axis equal;
subplot(3,1,2);scatter(data(:,1),data(:,2),10,ids,'filled');title('Clusters found by k-means- euclidean distance');axis equal;
%subplot(3,1,3);scatter(data(:,1),data(:,2),10,ids2,'filled');title('Clusters found by Spectral clustering - cosine');axis equal;

