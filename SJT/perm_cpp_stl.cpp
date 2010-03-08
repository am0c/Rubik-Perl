#include <vector>
#include <algorithm>

using namespace std;

int main() {
	vector<int> v;
	for (int i = 1; i < 10; ++i) v.push_back(i);
	while (next_permutation(v.begin(), v.end()));
	return 0;
}
