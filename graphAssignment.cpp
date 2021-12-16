#include <bits/stdc++.h>
using namespace std;

#define MAX_INT 9999

struct Node {
  int vert, depth;
};

class Graph {
private:
  int n;

  int g[10][10];

  int minDistance(int dist[], bool inc[]) {
    int min = MAX_INT, min_index;

    for (int v = 0; v < n; v++)
      if (inc[v] == false && dist[v] <= min)
        min = dist[v], min_index = v;

    return min_index;
  }

  int findTotalPaths(int src, int dst, int m) {
    queue<Node> q;
    q.push({src, 0});

    int count = 0;

    while(!q.empty()) {
      Node node = q.front();
      q.pop();

      int x = node.vert;
      int depth = node.depth;

      if(x == dst && depth == m) {
        count++;
      }

      if(depth > m) {
        break;
      }
      for(int i = 0; i<n; i++) {
        if(g[x][i] != MAX_INT) {
          q.push({i, depth + 1});
        }
      }
    }

    return count;
  }

public:

  Graph(int x) {
    n = x;

    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        g[i][j] = MAX_INT;
      }
    }
  }

  void addEdge(char a, char b, int w) {
    int x = int(a) - int('A');
    int y = int(b) - int('A');
    if(x < 0 || x >= n) {
      cout<< "Vertex " << a << " does not exists!";
    }
    if(y < 0 || y >= n) {
      cout<< "Vertex " << b << " does not exists!";
    }
    if(a==b) {
      cout<< "Same vertices";
    } else {
      g[x][y] = w;
    }
  }

  void findPath(queue<char> &q) {
    int N = q.size();
    int dist = 0;

    for(int i = 0; i < N-1; i++) {
      int a = int(q.front()) - int('A');
      q.pop();
      int b = int(q.front()) - int('A');
      if(g[a][b] != MAX_INT) {
        dist += g[a][b];
      } else {
        cout<<"NO SUCH ROUTE";
        return;
      }
    }
    q.pop();
    cout<< dist;
  }

  void findNumberOfPathsWithMaxStops(char a, char b, int maxStops) {
    int src = int(a) - int('A');
    int dst = int(b) - int('A');

    int paths = 0;

    for(int i = 1; i <= maxStops; i++) {
      paths += findTotalPaths(src, dst, i);
    }
    cout<<paths;
  }

  void findNumberOfPathsWithExactStops(char a, char b, int stops) {
    int src = int(a) - int('A');
    int dst = int(b) - int('A');

    int paths = findTotalPaths(src, dst, stops);
    cout<<paths;
  }

  void findNumberOfPathsWithMaxDist(char a, char b, int max) {
    int src = int(a) - int('A');
    int dst = int(b) - int('A');

    queue<Node> q;
    q.push({src, 0});

    int count = 0;

    while(!q.empty()) {
      Node node = q.front();
      q.pop();

      int x = node.vert;
      int depth = node.depth;

      if(x == dst && depth < max && depth != 0) {
        count++;
      }

      if(depth < max) {
        for(int i = 0; i<n; i++) {
          if(g[x][i] != MAX_INT) {
            q.push({i, depth + g[x][i]});
          }
        }
      }

    }
    cout<< count;
  }

  void shortestPath(char a, char b) {
    int src = int(a) - int('A');
    int dst = int(b) - int('A');
    int dist[n];
    bool inc[n];

    for(int i = 0; i<n; i++) {
      dist[i] = MAX_INT;
      inc[i] = false;
    }

    dist[src] = 0;

    for(int count = 0; count < n-1; count++) {
      int u = minDistance(dist, inc);
      inc[u] = true;

      for(int i = 0; i<n; i++) {
        if(!inc[i] && g[u][i] != MAX_INT && dist[u] != MAX_INT && dist[i] > dist[u] + g[u][i]) {
          dist[i] = dist[u] + g[u][i];
        }
      }
    }

    dist[src] = MAX_INT;
    if(src == dst) {
      for(int i = 0; i<n; i++) {
        if(g[i][dst] != MAX_INT && dist[i] != MAX_INT && dist[dst] > dist[i] + g[i][dst]) {
          dist[dst] = dist[i] + g[i][dst];
        }
      }
    }

    cout<< dist[dst];
  }
};

int main() {
  Graph graph = Graph(5);
  graph.addEdge('A', 'B', 5);
  graph.addEdge('B', 'C', 4);
  graph.addEdge('C', 'D', 8);
  graph.addEdge('D', 'C', 8);
  graph.addEdge('D', 'E', 6);
  graph.addEdge('A', 'D', 5);
  graph.addEdge('C', 'E', 2);
  graph.addEdge('E', 'B', 3);
  graph.addEdge('A', 'E', 7);

  int count = 1;
  queue<char> q;
  q.push('A');
  q.push('B');
  q.push('C');
  cout<< "Output # " << count <<" : ";
  graph.findPath(q);
  count++;
  cout<<endl;

  q.push('A');
  q.push('D');
  cout<< "Output # " << count <<" : ";
  graph.findPath(q);
  count++;
  cout<<endl;

  q.push('A');
  q.push('D');
  q.push('C');
  cout<< "Output # " << count <<" : ";
  graph.findPath(q);
  count++;
  cout<<endl;

  q.push('A');
  q.push('E');
  q.push('B');
  q.push('C');
  q.push('D');
  cout<< "Output # " << count <<" : ";
  graph.findPath(q);
  count++;
  cout<<endl;

  q.push('A');
  q.push('E');
  q.push('D');
  cout<< "Output # " << count <<" : ";
  graph.findPath(q);
  count++;
  cout<<endl;

  cout<< "Output # " << count <<" : ";
  graph.findNumberOfPathsWithMaxStops('C', 'C', 3);
  count++;
  cout<<endl;

  cout<< "Output # " << count <<" : ";
  graph.findNumberOfPathsWithExactStops('A', 'C', 4);
  count++;
  cout<<endl;

  cout<< "Output # " << count <<" : ";
  graph.shortestPath('A', 'C');
  count++;
  cout<<endl;

  cout<< "Output # " << count <<" : ";
  graph.shortestPath('B', 'B');
  count++;
  cout<<endl;

  cout<< "Output # " << count <<" : ";
  graph.findNumberOfPathsWithMaxDist('C', 'C', 30);

  return 0;

}
