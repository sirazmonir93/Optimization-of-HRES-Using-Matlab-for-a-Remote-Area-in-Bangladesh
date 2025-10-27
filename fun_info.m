function [lowerbound,upperbound,dimension,fitness] = fun_info(F)


switch F
    case 'F1'
        fitness = @F1;
        lowerbound=-100;
        upperbound=100;
        dimension=30;
        
    case 'arif'
        fitness = @arif;
        lowerbound=[1 1 1 1];
        upperbound=[10000 10000 10000 10000];
        dimension=4;
                   
end

end

% F1

function R = F1(x)
R=sum(x.^2);
end



% F22

function R = F22(x)
aSH=[4 4 4 4;1 1 1 1;8 8 8 8;6 6 6 6;3 7 3 7;2 9 2 9;5 5 3 3;8 1 8 1;6 2 6 2;7 3.6 7 3.6];
cSH=[.1 .2 .2 .4 .4 .6 .3 .7 .5 .5];

R=0;
for i=1:7
    R=R-((x-aSH(i,:))*(x-aSH(i,:))'+cSH(i))^(-1);
end
end

% F23

function R = F23(x)
aSH=[4 4 4 4;1 1 1 1;8 8 8 8;6 6 6 6;3 7 3 7;2 9 2 9;5 5 3 3;8 1 8 1;6 2 6 2;7 3.6 7 3.6];
cSH=[.1 .2 .2 .4 .4 .6 .3 .7 .5 .5];

R=0;
for i=1:10
    R=R-((x-aSH(i,:))*(x-aSH(i,:))'+cSH(i))^(-1);
end
end

function R=Ufun(x,a,k,m)
R=k.*((x-a).^m).*(x>a)+k.*((-x-a).^m).*(x<(-a));
end