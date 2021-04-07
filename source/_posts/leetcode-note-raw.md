---
title: LeetCode刷题笔记（归档1）
date: 2021-02-24 16:05:02
categories: 算法练习
tags:
- 算法
---


### 1. Two Sum

https://leetcode-cn.com/problems/two-sum/

题意：

*给定一个整数数组 nums 和一个目标值 target，请你在该数组中找出和为目标值的那 两个 整数，并返回他们的数组下标。*

思路：

一次遍历+Hash表，以来访-查登记表-登记的思想理解

代码：

```java
class Solution {
    public int[] twoSum(int[] nums, int target) {
        Map<Integer,Integer> regi_book = new HashMap<>();
        for(int i = 0;i<nums.length;i++){
            int part_num = target - nums[i];
            if(regi_book.containsKey(part_num))
                return new int[] { regi_book.get(part_num),i };
            regi_book.put(nums[i],i);
        }
        throw new IllegalArgumentException("No two sum solution");
    }
}
```

### 43. 字符串模拟乘法

https://leetcode-cn.com/problems/multiply-strings/

题意：

*给定两个以字符串形式表示的非负整数 num1 和 num2，返回 num1 和 num2 的乘积，它们的乘积也表示为字符串形式。*  

思路：

和标准乘法处理方法（用其中一个数的每一位去乘另一乘数整体）基本一致，只是需要寻找两乘数的位数与结果位数的关系（ num1 的 i 位置数字与 num2 的 j 位数字影响 sum 的 i + j 和 i + j + 1 位）来优化算法  

> 注意：

```java
class Solution {
    public String multiply(String num1, String num2) {
        if(num1.equals("0") || num2.equals("0")){
            return "0";
        }
        int res[] = new int[num1.length() + num2.length()]; //乘积结果位数最大值是二者长度之和
        for(int i = num1.length()-1;i >= 0 ;i--){
            int n1 = num1.charAt(i) - '0';
            for(int j = num2.length()-1;j >= 0;j--){
                int n2 = num2.charAt(j) - '0';
                int sum = (res[i+j+1] + n1*n2);
                res[i+j] += sum/10;
                res[i+j+1] = sum%10; //已经在sum的地方加过原值了，所以是=不是+=
            }
        }

        StringBuilder builder = new StringBuilder();
        for(int i=0;i<res.length;i++){
            if(i == 0 && res[i] == 0) continue;
            builder.append(res[i]);
        }
        return builder.toString();
    }
}
```

### 387. 无重复字符的最长字串

https://leetcode-cn.com/problems/first-unique-character-in-a-string/

*给定一个字符串，请你找出其中不含有重复字符的最长子串的长度。*  

思路：

滑动窗口类问题，设置一个Hashset判重。新成员（右侧的）出现重复则移动左指针（i++），并且将出去的元素移出 HashSet ，判重失败则一直移动右指针至判重成功，然后记录每次长度取最大值

```java
class Solution {
    public int lengthOfLongestSubstring(String s) {
        Set<Character> set = new HashSet<>();
        int maxlen = 0;
        int n = s.length();
        // 右指针
        int rp = 0;
        // i 代表左指针
        for(int i = 0;i<n;i++){
            if(i != 0){
                set.remove(s.charAt(i-1));
            }
            while(rp < n && !set.contains(s.charAt(rp))){
                set.add(s.charAt(rp));
                rp++;
            }
            maxlen = Math.max(maxlen,rp-i);
        }
        return maxlen;
    }
}
```

### 141. 环形链表

https://leetcode-cn.com/problems/linked-list-cycle/

*给定一个链表，判断链表中是否有环。*  

思路：

设置两个快慢指针，快指针每次循环next一次，慢指针每两次循环next一次，若循环期间快指针地址与慢指针相同（快指针追上慢指针），则说明链表有环。  

### 56. 合并区间

https://leetcode-cn.com/problems/merge-intervals/

*给出一个区间的集合，请合并所有重叠的区间。*

思路：

先对int的区间集合**按左区间排序**，可知能够合并的区间必然在排序中连续，通过指针从左到右遍历并尝试合并每个重叠的区间（条件：新区间左边界<旧区间右边界）并合并（Max(old.right,new.right)），即可得结果。

```java
class Solution {
    public int[][] merge(int[][] intervals) {
        List<int[]> res = new ArrayList<>();
        if (intervals.length == 0 || intervals == null)
            return res.toArray(new int[0][]);
        // 注意 sort 的使用，提供了自己设定的比较方法
        Arrays.sort(intervals, (a,b) -> a[0] - b[0]);
        int i = 0;
        while(i < intervals.length){
            int left = intervals[i][0];
            int right = intervals[i][1];
            // 因为不满足的区间不能算入，所以需要i+1向前多试探一项
            // 当遍历的区间左边界不再小于右边界时就没法合并了，跳出
            while(i < intervals.length - 1 && intervals[i+1][0] <= right){
                // 如果下一个区间和本区间重叠，取它的右边界作为新的右边界
                right = Math.max(intervals[i+1][1],right);
                i++;
            }
            // 遍历结束或者遍历到离下一个区间有空隙，将当前保存的结果合并并放入结果集
            res.add(new int[]{left,right});
            // 从下一个区间再继续
            i++;
        }
        return res.toArray(new int[0][]);
    }
}
```

### 546. 移除盒子

https://leetcode-cn.com/problems/remove-boxes/

*给出一些不同颜色的盒子，盒子的颜色由数字表示，即不同的数字表示不同的颜色。**你将经过若干轮操作去去掉盒子，直到所有的盒子都去掉为止。每一轮你可以移除具有相同颜色的连续 k 个盒子（k >= 1），这样一轮之后你将得到 k\*k 个积分。当你将所有盒子都去掉之后，求你能获得的最大积分和。*

思路：

**明显的动态规划**。难点在于函数信息的获取，仅靠f(l,r)的左边界，右边界两个信息来探索移除盒子的步骤是不够的，比如{3,4,2,4,4}最优操作需要先移除2，然后移除3个4，这样会导致原本的连续串分割为两个，并且**两个串之间存在联系，无法用f(l,r)来描述**，所以需要更多信息  至此，可以用**f(l,r,k)**来表示移除区间[l,r]加上区间右侧等于box[r]的k个增量元素组成这个序列的最大积分，分解时，先对序列右侧相等的k个数划成k增量，序列的结果就可以分解为“**以相同box[r]值为r的[l,r]区间+k增量”+“两部分间的空隙区间[r+1,l-k]+0增量**”，对于不同空隙划分求最大值，即可满足状态转移的需求。  

```java
class Solution {
    public int removeBoxes(int[] boxes) {
        int l = 0;int r = boxes.length-1;int add = 0;
        int[][][] dp = new int[100][100][100];
        // 自上到下的遍历顺序
        return calculateMaxScore(boxes,dp,l,r,add);
    }

    public int calculateMaxScore(int[] boxes,int[][][] dp,int l,int r,int add){
        if(l > r) return 0;
        // 如果有缓存，使用缓存数据
        if(dp[l][r][add] != 0) return dp[l][r][add];
        // 起始时先判断右侧有多少和右区间相同的增量增量
        while(r > l && boxes[r-1] == boxes[r]){
            r--;
            add++;
        }
        // 开始的时候增量和[l,r]之间没有空隙，不需要计算空隙之间的值（或者说空隙已经在上一层计算过了）
        dp[l][r][add] = calculateMaxScore(boxes,dp,l,r-1,0) + (add+1)*(add+1);
        // 遍历该区间下（l->r）所有组合方式的最大值
        for(int i = r-1;i >= l;i--){
            // 寻找本区间内【内部】存在的和区间右边相等的值，生成一组新组合
            // 所有组合方式的最大值将会加到该区间上
            if(boxes[i] == boxes[r])
                // 结果：[l,i]+增量的递归结果 + 空隙的递归结果
                dp[l][r][add] = Math.max(dp[l][r][add],
                                         calculateMaxScore(boxes,dp,l,i,add+1)
                                         +calculateMaxScore(boxes,dp,i+1,r-1,0));
        }
        return dp[l][r][add];
    }
}
```

### 53. 最大子序和

https://leetcode-cn.com/problems/maximum-subarray/

*求一个数字序列的最大连续字串和*

**思路：**

因为要求连续性，所以不能用贪心的方法（即区间最大不能满足整体最大）

**动态规划**：需要认识到该问题的答案并不是动态规划后f(i)的值本身，而是所有f(i)的最大值，f(i)的最优决策为max( f(i-1)加上n[i]的值 ， 以n[i]独立作为一行新值 ），两个决策都可以保证f(i)的**连续性**。 

```java
class Solution {
    public int maxSubArray(int[] nums) {
        int ans = nums[0];
        int max_preN = 0;
        for(int num:nums){
            // 因为即使遍历位置为负数，不能因为其减少结果就不选择（不同于贪心），而是先选择再看整体结果
            // 相对的，如果遍历位置结果已经高于加起来的结果，那么可以选择舍弃前面的结果
            max_preN = Math.max(max_preN+num,num);
            ans = Math.max(max_preN,ans);
        }
        return ans;
    }
}
```

### 733. 图像渲染

https://leetcode-cn.com/problems/flood-fill/

思路：

最基础的遍历问题，重点是了解 dfs 和 bfs 的基本使用

四方向探索：存放两个增量数组dx[],dy[]，以for(i=0-4)的循环进行x+dx[i],y+dy[i]的增量，减少代码量，并注意边界范围

由于该问题自然改变原值效果，所以不需要另外建立数组保存遍历记录

bfs：关键是一个先进先出**Queue队列**，对于这种包含两维信息的数据，用Queue<int[]>即可（仅使用data[0]和data[1]保存数据，添加数据时：queue.offer(new int[]{x,y})

dfs：另外创建一个dfs函数进行递归运算即可（保证参数信息足够，否则使用全局变量/类成员变量）  

```java
// dfs
class Solution {
    int[] ax = {1, 0, 0, -1};
    int[] ay = {0, -1, 1, 0};
    public int[][] floodFill(int[][] image, int sr, int sc, int newColor) {
        if(newColor == image[sr][sc]){
            return image;
        }
        int origin = image[sr][sc];
        int length = image.length;
        int width = image[0].length;
        dfs(image,sr,sc,origin,newColor);

        return image;
    }

    public void dfs(int[][] image, int x, int y,int origin,int newColor){
        image[x][y] = newColor;
        for(int i=0;i<4;i++){
            int mx = x + ax[i]; int my = y + ay[i];
            // 最好改成 isBorder 函数
            if(mx >= 0 && my >= 00 && mx < image.length && my < image[0].length && image[mx][my] == origin){
                dfs(image,mx,my,origin,newColor);
            }
        }
    }
}

// bfs
class Solution {
    int[] ax = {1, 0, 0, -1};
    int[] ay = {0, -1, 1, 0};
    public int[][] floodFill(int[][] image, int sr, int sc, int newColor) {
        if(newColor == image[sr][sc]){
            return image;
        }
        Queue<int[]> queue = new LinkedList<>();
        int origin = image[sr][sc];
        int length = image.length;
        int width = image[0].length;
        queue.offer(new int[]{sr,sc});
        image[sr][sc] = newColor;

        while(!queue.isEmpty()){
            int temp[] = queue.poll();
            int x = temp[0]; int y = temp[1];
            for(int i=0;i<4;i++){
                int mx = x + ax[i]; int my = y + ay[i];
                // 最好改成 isBorder 函数
                if(mx >= 0 && my >= 00 && mx < length && my < width && image[mx][my] == origin){
                    queue.offer(new int[]{mx, my});
                    image[mx][my] = newColor;    
                }
            }
        }
        return image;
    }
}
```

### 679. 24点

https://leetcode-cn.com/problems/24-game/

*你有 4 张写有 1 到 9 数字的牌。你需要判断是否能通过加减乘除的运算得到24*

**思路：**

对于4个数字和3次四则运算的组合时有限的，通过**【回溯法】直接遍历是可能的**，每次回溯运算将原数组未参加运算的数字+本次计算结果放入一个新数组，并用该数组参加第二次回溯，回溯运算结束后将该计算结果移除数组，匹配下一种可能运算（运算数字不变）

这体现了对算法问题最通用的一种解题方法：

【**穷举各种可能性，再观察穷举过程进行进一步优化**】

```java
class Solution {
    static final int TARGET = 24;
    static final double MIN_LIMIT = 1e-6;
    static final int ADD = 0,  MULTIPLY = 1, SUBTRACT = 2, DIVIDE = 3;

    
    public boolean judgePoint24(int[] nums) {
        // 数字浮点化存储
        List<Double> numList = new ArrayList<>();
        for (int num : nums) {
            numList.add((double)num);
        }
        return solve(numList);
    }

    public boolean solve(List<Double> list){
        if(list.size() == 0){
            return false;
        }
        // 列表中只剩一个元素，只要与结果相等即为true
        if(list.size() == 1){
            // 浮点的等值判断需要容许一定误差
            return Math.abs(list.get(0) - TARGET) < MIN_LIMIT;
        }
        int size = list.size();
        // 第一运算数：i
        for(int i = 0; i < size; i++){
            // 第二运算数：j
            // 由于减，除法不具有交换性，所以[0,size-1]间的每个元素都要在第一，第二位置参与过计算
            for(int j = 0; j < size ; j++){
                if(i != j){
                    List<Double> list2 = new ArrayList<Double>();
                    for(int k = 0; k < size; k++){
                        if( k != i && k != j){
                            // 将未参与运算的其他数字移进下一次参加递归运算的list2
                            list2.add(list.get(k));
                        }
                    }

                    for(int k = 0; k < 4; k++){
                        // 优化：加乘法具有交换律，交换元素运算不变，可跳过
                        if(k < 2 && i > j){
                            continue;
                        }
                        // 对选择的两个数字进行运算符操作，结果直接放入下一次递归运算的list2
                        if (k == ADD) {
                            list2.add(list.get(i) + list.get(j));
                        } else if (k == MULTIPLY) {
                            list2.add(list.get(i) * list.get(j));
                        } else if (k == SUBTRACT) {
                            list2.add(list.get(i) - list.get(j));
                        } else if (k == DIVIDE) {
                            if(Math.abs(list.get(j)) < MIN_LIMIT){
                                continue;
                            } else {
                                list2.add(list.get(i) / list.get(j));
                            }
                        }
                        if (solve(list2)){
                            return true;
                        }
                        // 回溯完成后弹出末尾的计算结果元素，重新循环计算
                        list2.remove(list2.size() - 1);
                    }
                }
            }
        }
        return false;
    }
}
```

### 51. N皇后

https://leetcode-cn.com/problems/n-queens/

*n* *皇后问题研究的是如何将* *n* *个皇后放置在* *n**×**n* *的棋盘上，并且使皇后彼此之间不能相互攻击。*

思路：

标准的**回溯法**问题。

首先处理**斜线**：**row-column相同（右斜线）以及row+column相同（左斜线）。**

关键点仍然在于**如何选择使用正确的数据结构与容器**：

1. 虽然每个皇后的坐标是包含二维信息，但是该二维数据并不是**随机**分布，而是会遍历该二元信息，所以使用~~Deque<int[]>~~是没有必要的，并且由于每一行一个皇后，仅包含唯一列值用int[]即可（下标：行数，值：列数，同时用-1记录是否已选择过）
2. 基本思路：对于每一行上的皇后，都有(1~n)的可能个列可以选择，该列是否选择根据是否和前几个选择的皇后发生冲突判断，通过回溯方式进行皇后的摆放和撤回。
3. 对于这类判断重复的处理，优先考虑**HashSet**的容器，使用.contains()判断重复。**使用三个HashSet容器：columns,diagoals1,diagoals2来表示已经遍历过的皇后的三种信息（列不重复在for循环通过顺序选择列处理）**，若出现重复直接在循环中continue

```java
class Solution {
    public List<List<String>> solveNQueens(int n) {
        List<List<String>> solutions = new ArrayList<>();
        int[] queens = new int[n];
        Arrays.fill(queens,-1);
        Set<Integer> columns = new HashSet<Integer>();
        Set<Integer> diagoals1 = new HashSet<Integer>();
        Set<Integer> diagoals2 = new HashSet<Integer>();
        backtrack(solutions, queens, n, 0, columns, diagoals1, diagoals2);
        return solutions;
    }

    // 每次 backtrack 代表一个皇后的位置选择
    public void backtrack(List<List<String>> solutions, int[] queens,int n, int row, Set<Integer> columns, Set<Integer> diagoals1, Set<Integer> diagoals2)
    {
        //回溯终点的处理
        if (row == n) {
            List<String> board = generateBoard(queens,n);
            solutions.add(board);
        } else {
            for (int i = 0; i < n; i++) {
                // 如果已排列皇后不满足该选择的行条件，尝试下一个位置选择
                if (columns.contains(i)) {
                    continue;
                }
                int diagoal1 = row - i;
                // 如果已排列皇后不满足该选择的右斜线条件，尝试下一个位置选择
                if (diagoals1.contains(diagoal1)) {
                    continue;
                }
                int diagoal2 = row + i;
                // 如果已排列皇后不满足该选择的左斜线条件，尝试下一个位置选择
                if (diagoals2.contains(diagoal2)) {
                    continue;
                }
                // 如果都通过，以本次选择为基础继续搜索下一行皇后如何防止
                queens[row] = i;
                columns.add(i);
                diagoals1.add(diagoal1);
                diagoals2.add(diagoal2);
                backtrack(solutions, queens, n, row + 1, columns, diagoals1,diagoals2);
                // 回溯搜索结束后撤回本次选择的所有信息
                queens[row] = -1;
                columns.remove(i);
                diagoals1.remove(diagoal1);
                diagoals2.remove(diagoal2);
            }
        }
    }

    public List<String> generateBoard(int[] queens,int n){
        List<String> board = new ArrayList<String>();
        for (int i = 0; i < n; i++){
            char[] row = new char[n];
            Arrays.fill(row, '.');
            row[queens[i]] = 'Q';
            board.add(new String(row));
        }
        return board;
    }
}
```

### 347. 前K个高频元素

https://leetcode-cn.com/problems/top-k-frequent-elements/

*给定一个非空的整数数组，返回其中出现频率前 k高的元素*

思路：

考察优先队列的使用

```java
class Solution {
    public int[] topKFrequent(int[] nums, int k) {
        Map<Integer,Integer> map = new HashMap<>();
        for(int num:nums) {
           Integer count = map.get(num);
           map.put(num,count == null ? 1 : count+1); 
        }

        // 用优先队列，遍历原数组时按出现次数排序
        PriorityQueue<int[]> queue = new PriorityQueue<int[]>(
            new Comparator<int[]>() {
                public int compare(int[] m, int[] n) {
                    return m[1] - n[1];
                }
        });

        for (Map.Entry<Integer, Integer> entry : map.entrySet()) {
            int num = entry.getKey(), count = entry.getValue();
            if (queue.size() == k) {
                // 如果堆的元素个数等于 k，则检查堆顶与当前出现次数的大小。
                // 如果堆顶更大，说明至少有 k 个数字的出现次数比当前值大，故舍弃当前值；
                // 否则，就弹出堆顶，并将当前值插入堆中。
                if (queue.peek()[1] < count) {
                queue.poll();
                queue.offer(new int[]{num, count});
                }
            } else {
                queue.offer(new int[]{num, count});
            }
        }
        // 最后使得堆中的数据时前k大的
        int[] ans = new int[k];
        for(int i = 0; i < k; i++) {
            ans[i] = queue.poll()[0];
        }
        return ans;
    }

}
```

### 40. 组合总和 II

https://leetcode-cn.com/problems/combination-sum-ii/

*给定一个数组* *`candidates`* *和一个目标数* *`target`* *，找出* *`candidates`* *中所有可以使数字和为* *`target`* *的组合。*

思路：

容易想出该问题可以用回溯的方式解决，问题在于解集需要去重。

也就是说，存在这样一种情况：数组中重复的数与其他数字多次匹配，导致结果集出现重复结果。

所以，我们需要两步操作：1.对原数组**排序** 2.在循环-回溯过程中，对于循环过程，若存在*`candidates[i]`* *= `candidiates[i-1]`* 的情况（即该位置数字与上一次循环位置数字相同），**跳过该循环**，从而也阻止了该重复数组继续向下回溯其他数字的情况。

```java
class Solution {
    public List<List<Integer>> combinationSum2(int[] candidates, int target) {
        int length = candidates.length;
        Arrays.sort(candidates);
        List<List<Integer>> ans = new ArrayList<>();
        Deque<Integer> temp = new LinkedList<>();
        for(int i = 0; i < length; i++) {
            // 如果遍历的数和上一个相同，跳过
            if( i > 0 && candidates[i]==candidates[i-1] ) {
                continue;
            }
            temp.addFirst(candidates[i]);
            backtrack(candidates,0 + candidates[i],i+1,temp,ans,target);
            temp.removeFirst();
        }
        return ans;
    }

    void backtrack(int [] candidates,int sum,int start,Deque<Integer> temp,List<List<Integer>> ans,int target) {
        int length = candidates.length;
        if (sum > target || start > length)
            return;
        if (sum == target) {
            ans.add(new ArrayList(temp));
            return;
        }
        for(int j = start;j < length; j++) {
            // 如果遍历的数和上一个相同，跳过
            if( j > start && candidates[j]==candidates[j-1] ) {
                continue;
            }
            // 由于已排序，那么如果结果已经大于 target，说明已经不满足结果
            if(sum + candidates[j] > target)
                break;
            
            temp.addFirst(candidates[j]);
            backtrack(candidates,sum + candidates[j],j+1,temp,ans,target);
            temp.removeFirst();
        }
    }
}
```

### 216.组合总和 III 

https://leetcode-cn.com/problems/combination-sum-iii/

*找出所有相加之和为* ***n*** *的* ***k*** *个数的组合。组合中只允许含有 1 - 9 的正整数，并且每种组合中不存在重复的数字。要求：*

- *所有数字都是正整数。*
- *解集不能包含重复的组合。*

思路：

与前一题基本类似，同样使用循环选择+回溯。若要阻止重复，由于可选数字中不重复，只要保证每次取数大于前一次取数就行（`for (int i = num_chosen; i < 10; i++)`）

>  <u>”判断数字已经选择“的代码应该放在循环内的 continue 中而不是 for 语句中，放到 for 语句中会导致循环 break</u>

```java
import java.util.*;

public class CombinationSum3 {
        Set<Integer> temp = new HashSet<>();
        List<List<Integer>> ans = new ArrayList<>();
        //not use int[0];
        boolean[] isSelected = new boolean[10];
        public List<List<Integer>> combinationSum3(int k, int n) {
            isSelected[0] = true;
            solve(k,n,1);
            return ans;
        }

        void solve(int k,int n,int num_chosen) {
            // 当k降为1时，如果剩余所需和小于10，直接从剩余数字中选择即可
            if (k == 1 && n < 10) {
                // 保证n未被选过并且大于上次选择的数字（避免重复）
                if (!isSelected[n] && n > num_chosen) {
                    temp.add(n);
                    ans.add(new ArrayList(temp));
                    temp.remove(n);
                }
                return;
            }
            for (int i = num_chosen; i < 10; i++) {
                if(!isSelected[i])
                    if (n - i > 0) {
                        isSelected[i] = true;
                        temp.add(i);
                        //System.out.println(temp.toString());
                        solve(k - 1, n - i, i);
                        temp.remove(i);
                        isSelected[i] = false;
                    } else {
                        // 由于i顺序增加，n - i为负后没有必要再继续遍历
                        break;
                    }
            }
        }
}
```

### 637. 二叉树层平均值

https://leetcode-cn.com/problems/average-of-levels-in-binary-tree/

*给定一个非空二叉树, 返回一个由每层节点平均值组成的数组。*

思路：

基本为**层次遍历**，主要是要获取层数信息。和广度遍历不同的地方只在于，从每次while循环从每次弹出一个改为每次弹出当前队列内全部节点即可，将本次弹出的全部节点视为一个整体进行统计。

```java
class Solution {
    public List<Double> averageOfLevels(TreeNode root) {
        Queue<TreeNode> queue = new LinkedList<>();
        List<Double> averages = new ArrayList<>();
        queue.offer(root);
        int depth = 0;
        while(!queue.isEmpty()) {
            long sum = 0;
            int size = queue.size();
            // 先获取当前 queue 长度，保证该层的节点全部弹出
            // 在弹出的过程中同时把下一层的节点放进 queue 中
            for(int i = 0; i < size; i++) {
                TreeNode temp = queue.remove();
                if(temp.left != null) queue.offer(temp.left);
                if(temp.right != null) queue.offer(temp.right);
                sum += temp.val;
            }
            averages.add((double)sum / size);
        }
        return averages;
    }
}
```

### 474. 一和零（N）

https://leetcode-cn.com/problems/ones-and-zeroes/

*使用给定的* ***m*** *个* *`0`* *和* ***n*** *个* *`1`* *，找到能拼出存在于给定数组中的字符串的（不重复的）最大数量。每个* *`0`* *和* *`1`* *至多被使用一次。*

思路：**动态规划**。

> 动态规划最难的地方在于，无法对问题进行适当的建模，即，想不出动态转移方程。
>
> 首先我们需要掌握动态规划的精神：
>
> （我的理解）首先动态规划仍然是一种**遍历**过程，这种遍历体现在其底层运行过程中。
>
> 其高层的思想是：假设我们的（以最优为目标的）问题包含许多种**状态**，每个状态是一个f(a,b...)值，而我们的最终解f(x1,x2...)是其中的状态之一。
>
> 我们假设这样一个返回最优解的函数存在，我们需要探究如何在其他最优子状态存在的前提下，从其他子状态得到我们最终状态。
>
> 而这样一个“得到”的过程，实际上是**决策**的一种体现。
>
> 我们不应该一定要从dp[i-1]步进到dp[i]来进行状态转移，而是应该关注具体的**决策**过程，根据决策决定我们应该如何在状态间进行转移
>
> 所以我们可以尝试先进行人工求解，然后注意自己在人工求解的过程中，进行了哪些决策操作，从而构造动态转移方程
>
> 除此之外

比如，在该问题中，我们这样思考：

**最优目标**：可构造的 strs 中字符串的个数

**可变量和有限量**：构造的字符子集中使用 0  的个数和 1 的个数，分别有上限 m 和 n

**数据的转换方式**：每多一个构造的字符串，使用 0 的个数和 1 的个数分别会增加（可用数减少）

我们关注该过程发生时的**数据变化**：如果我们某个时间点选择构造了一个字符串，那么：

一、我们构造出的字符串数会【在该时间点已构造出的字符串数基础上】增加1，

二、在0，1数字够的情况下，我们的0，1数字数会减少该字符串数，如果减到0以下，意味着我们不够构造该字符串

同时，我们也可以选择不构造该字符串，当我们的解完成时，【所有字符串都有一个确定的被构造/未被构造的二元状态】

这个时候我们就得到了我们的决策过程：（对于所有字符串中的某个字符串），我们选择构造字符串，或者我们选择不构造一个字符串

决策确定了，下一步我们需要确定**如何在决策中选取最优值**：

**假设我们已经拥有了任何状态下构造出字符串的最优解**，那么这个状态和当前0，1数字数（m,n）相关，那么，我们将这个状态替换上文的【该事件点】，根据决策与决策发生时的数据转移过程，我们可以得到我们的动态转移方程：**`dp[zeroes][ones] = Math.max(1 + dp[zeroes - count[0]][ones - count[1]], dp[zeroes][ones]);`**

```java
class Solution {
    public int findMaxForm(String[] strs, int m, int n) {
        int[][] dp = new int[m+1][n+1];
        for(String str : strs) {
            int[] count01 = countZerosOnes(str);
            // 由于当剩余0，1存量不满足str需求时无法+1，所以直接在循环处就判断。
            // 这里的0，1共同相当于0-1背包问题的容量资源
            // 如果不倒序会导致重复计算问题，所以需要
            for(int zeros = m; zeros >= count01[0]; zeros--) {
                for(int ones = n; ones >= count01[1]; ones--) {
                    dp[zeros][ones] = Math.max(1+dp[zeros-count01[0]][ones-count01[1]],dp[zeros][ones]);
                }
            }
        }
        return dp[m][n];
    }

    static int[] countZerosOnes(String str) {
        char[] chArray = str.toCharArray();
        int[] ans = new int[2];
        for(char c : chArray) {
            if(c == '0')
                ans[0]++;
            else if(c == '1')
                ans[1]++;
        }
        return ans;
    }
}
```

### 79. 单词搜索

题意：

*给定一个二维网格和一个单词，找出该单词是否存在于网格中。*

标签：

#回溯

思路：

**回溯**（深度优先）

> 写的时候小错误太多，注意事先做好大致规划

```java
// 改进点：
// 用list保存当前为止与历史位置没必要，改为传参传递位置即可
// 通过直接修改原数组来代替 visited数组
class Solution {
    int[] dx = {1,0,-1,0};
    int[] dy = {0,1,0,-1};
    int height;
    int width;
    // 全局
    boolean flag = false;
    List<int[]> list = new ArrayList<>();

    public boolean exist(char[][] board, String word) {
        char[] cword = word.toCharArray();
        height = board.length;
        width = board[0].length;
        boolean[][] isListed = new boolean[height][width];
        // 任一位置为出发点开始试探，保证从所有位置开始进行过搜索
        for(int i = 0; i < height; i++) {
            for(int j = 0; j < width; j++) {
                if(board[i][j] == cword[0]) {
                    list.add(new int[]{i,j});
                    isListed[i][j] = true;
                    backtrack(cword,isListed,board,1);
                    isListed[i][j] = false;
                    list.remove(list.size()-1);
                }
            }
        }
        return flag;
    }

    public void backtrack(char[] cword,boolean isListed[][],char[][] board,int p) {
        if(p == cword.length) {
            flag = true;
            return;
        }
        if (flag == true) {
            return;
        }
        int[] block = list.get(list.size()-1);
        for(int j = 0; j < 4; j++) {
            int addx = block[0] + dx[j];
            int addy = block[1] + dy[j];
            if (checkborder(addx,addy,height,width) && !isListed[addx][addy] && board[addx][addy] == cword[p]){
                list.add(new int[]{addx,addy});
                isListed[addx][addy] = true;
                backtrack(cword,isListed,board,p+1);
                isListed[addx][addy] = false;
                list.remove(list.size()-1);
            }
        }
    }

    public static boolean checkborder(int x,int y,int h,int w) {
        if(x >= h || y >= w)
            return false;
        if(x < 0 || y < 0)
            return false;
        return true;
    }
}
```

另外再提供一种更简洁的python做法

```python
def exist(self, g: List[List[str]], word: str) -> bool:
    R, C = len(g), len(g[0])

    def spread(i, j, w):
        if not w:
            return True
        # 将遍历过的点覆盖，保证没法再次踏上该位置
        original, g[i][j] = g[i][j], '-'
        spreaded = False
        for x, y in ((i-1, j), (i+1, j), (i, j-1), (i, j+1)):
            if (0<=x<R and 0<=y<C and w[0]==g[x][y]
                    and spread(x, y, w[1:])):
                spreaded = True
                break
        g[i][j] = original
        return spreaded

    for i in range(R):
        for j in range(C):
            if g[i][j] == word[0] and spread(i, j, word[1:]):
                return True
    return False
```

### 解数独

题意：

*给定一个已分配初始值的9x9二维数独图，假设只有唯一解，返回该唯一解的数独图。*

标签：

#回溯

思路：

**dfs回溯**。将给定的图中留空的坐标保存为一个List，回溯时通过遍历该List试探可能的值。

建立三个布尔数组row[][]，line[][]，block[][][]，分别表示某值是否在某个row[i]，line[i]，block[i][j]上出现过，根据该结果决定是否能填入某个值。和 N 皇后基本类似

```java
class Solution {
    boolean[][] line = new boolean[9][9];   //y值是否在x列出现过
    boolean[][] row = new boolean[9][9];    //y值是否在x行出现过
    boolean[][][] block = new boolean[3][3][9];     //z值是否在位置为(x,y)的块中出现过
    List<int[]> empty = new ArrayList<>();
    boolean flag = false;
    public void solveSudoku(char[][] board) {
        // 初始化，记录棋盘信息
        for (int i = 0; i < 9; i++) {
            for (int j = 0; j < 9; j++) {
                if(board[i][j] == '.'){
                    empty.add(new int[]{i,j});
                } else {
                    // int[9][9] 的数组下标实际上为 0~8
                    // 实际值与位置均需要偏移1
                    int digit = board[i][j] - '0' - 1;
                    line[j][digit] = true;
                    row[i][digit] = true;
                    block[i/3][j/3][digit] = true;
                }
            }
        }

        backdfs(board,0);
    }

    public void backdfs(char[][] board,int pos) {
        if (pos == empty.size()) {
            flag = true;
            return;
        }

        int[] space = empty.get(pos);
        int x = space[0]; int y = space[1];
        for (int digit = 0; digit < 9 && !flag; digit ++) {
            if (!row[x][digit] && !line[y][digit] && !block[x/3][y/3][digit] ) {
                row[x][digit] = line[y][digit] = block[x / 3][y / 3][digit] = true;
                board[x][y] = (char) (digit + '0' + 1);
                backdfs(board, pos + 1);
                row[x][digit] = line[y][digit] = block[x / 3][y / 3][digit] = false;
            }
        }
    }
}
```

### 501.二叉搜索树的众数

题干：

*给定一个有相同值的二叉搜索树（BST），找出BST中的所有众数（以尽量小的空间开销）*

标签：

#二叉搜索树

思路：

不考虑空间：中序遍历扫描出序列结果，然后再一边扫描统计

不使用额外空间，仅递归：因为 BST 中序遍历结果有序，可以通过三个变量（curr，cur_count，max）一次遍历就得出结果

不递归，**Morris**：基本原理：**每次遍历一个节点时，将该节点的前驱节点右指针指向本节点**

其他细节：

1. 如果需要数组输出，可以先使用 **List** 保存结果集，最后统一转换即可

2. 递归（先序遍历等）对**基本类型参数**的修改不正确，最好使用全局类变量

```java
//Morris 解法
class Solution {
    int base, count, maxCount;
    List<Integer> answer = new ArrayList<Integer>();

    public int[] findMode(TreeNode root) {
        TreeNode cur = root, pre = null;
        while (cur != null) {
            // 当前节点无左子树，遍历该节点，之后移动到右子树
            if (cur.left == null) {
                update(cur.val);
                cur = cur.right;
                continue;
            }
            // 有左子树，设置pre指针搜索左子树前驱节点
            pre = cur.left;
            // 不断搜索pre指向节点的右节点，直到pre无右子树或者右节点指向自己为止
            while (pre.right != null && pre.right != cur) {
                pre = pre.right;
            }
            // 如果遍历到pre无右子树,说明前驱节点就是 pre
            if (pre.right == null) {
                pre.right = cur;
                cur = cur.left;
            } else {	//如果遍历到右子树指向自己
                pre.right = null;
                update(cur.val);
                cur = cur.right;
            }
        }
        int[] mode = new int[answer.size()];
        for (int i = 0; i < answer.size(); ++i) {
            mode[i] = answer.get(i);
        }
        return mode;
    }

    public void update(int x) {
        if (x == base) {
            ++count;
        } else {
            count = 1;
            base = x;
        }
        if (count == maxCount) {
            answer.add(base);
        }
        if (count > maxCount) {
            maxCount = count;
            answer.clear();
            answer.add(base);
        }
    }
}
```

### 235. 二叉搜索树的最近公共祖先

题干：

*给定一个二叉搜索树, 找到该树中两个指定节点的最近公共祖先。*

标签：

#二叉搜索树

思路：

基本思路都是根据二叉搜索树性质，从根节点开始根据指定节点信息向下搜索，直到获取到共同信息为止，有两次遍历和一次遍历两种方法

两次遍历：通过两次遍历定位两个节点，并且记录经过的节点。显然，q与p的最近公共子节点就是它们路径上的分岔点，即最后一个相同的节点。所以只需找出最大的编号使其满足：path_p[i] = path_q[i] 即可

**一次遍历**：从根节点向下遍历，如果遍历到的节点值第一次**处于q与p中间（此时q与p第一次处于两个子树）**，那么说明达到分岔点。

```java
class Solution {
    public TreeNode lowestCommonAncestor(TreeNode root, TreeNode p, TreeNode q) {
        TreeNode ancestor = root;
        while (ancestor != null) {
            if (ancestor.val < p.val && ancestor.val < q.val) {
                ancestor = ancestor.right;
            }
            else if (ancestor.val > p.val && ancestor.val > q.val ) {
                ancestor = ancestor.left;
            }
            else {
                break;
            }
        }
        return ancestor;
    }
}
```

### J-42. 连续子数组最大和

题意：

*输入一个整型数组，数组中的一个或连续多个整数组成一个子数组。求所有子数组的和的最大值。要求时间复杂度为O(n*)。

标签：

#dp

思路：

注意不能直接用 dp[i] 代表“长度为i的数组的所有子数组和最大值”，信息量不够，而是应该代表**【以元素 nums[i] 为结尾的连续子数组的最大和】** ，最后的结果通过比较 dp[0] ~ dp[n] 得出

dp[i] 可以从 dp[i-1] 过渡而来，dp[i] 可以选择保留 dp[i-1] 或者不保留，即 dp[i] = nums[i] (dp[i-1] <= 0) 或 dp[i-1] + nums[i] (dp[i-1] >= 0)

```java
class Solution {
    public int maxSubArray(int[] nums) {
        int n = nums.length;
        int[] dp = new int[n];
        dp[0] = nums[0];
        int max = dp[0];
        for (int i = 1; i < n; i++) {
            dp[i] = dp[i-1] <= 0 ? nums[i] : dp[i-1] + nums[i];
            max = Math.max(dp[i],max);
        }
        return max;
    }
}
```

### 198. 打家劫舍

https://leetcode-cn.com/problems/house-robber

题意：

*你是一个专业的小偷，计划偷窃沿街的房屋。每间房内都藏有一定的现金，影响你偷窃的唯一制约因素就是相邻的房屋装有相互连通的防盗系统，如果两间相邻的房屋在同一晚上被小偷闯入，系统会自动报警。给定一个代表每个房屋存放金额的非负整数数组，计算你 不触动警报装置的情况下 ，一夜之内能够偷窃到的最高金额。*

思路：

典型的 0-1 线性的动态规划问题。

对于某个 dp[i]，如果选择了上一个房子就不能选本房子的现金（nums[i]），所以递归公式为：**dp[i]=max(nums[i] + dp[i−2], dp[i−1])**

```java
public int rob(int[] nums) {
    int n = nums.length;
  
    // 处理当数组为空或者数组只有一个元素的情况
    if(n == 0) return 0;
    if(n == 1) return nums[0];

    // 定义一个 dp 数组，dp[i] 表示到第 i 个元素为止我们所能收获到的最大总数
    int[] dp = new int[n];

    // 初始化 dp[0]，dp[1]
    dp[0] = nums[0];
    dp[1] = Math.max(nums[0], nums[1]);

    // 对于每个 nums[i]，考虑两种情况，选还是不选，然后取最大值
    for (int i = 2; i < n; i++) {
        dp[i] = Math.max(nums[i] + dp[i - 2], dp[i - 1]);
    }
  
    return dp[n - 1];
}
```

### 516. 最长回文子序列

```java
public static int LPS(String s) {
    int n = s.length();
    // 定义 dp 矩阵，dp[i][j] 表示从字符串第 i 个字符到第 j 个字符之间的最长回文
    int[][] dp = new int[n][n];
  
    // 初始化 dp 矩阵，将对角线元素设为 1，即单个字符的回文长度为 1
    for (int i = 0; i < n; i++) dp[i][i] = 1;
    
    // 从长度为 2 开始，尝试将区间扩大，一直扩大到 n
    for (int len = 2; len <= n; len++) {
        // 在扩大的过程中，每次都得出区间的其实位置i和结束位置j
        for (int i = 0; i < n - len + 1; i++) {
            int j = i + len - 1;
      
            // 比较一下区间首尾的字符是否相等，如果相等，就加2；如果不等，从规模更小的字符串中得出最长的回文长度
            if (s.charAt(i) == s.charAt(j)) {
                dp[i][j] = 2 + (len == 2 ? 0: dp[i + 1][j - 1]);
              } else {
                dp[i][j] = Math.max(dp[i + 1][j], dp[i][j - 1]);
              }
        }
    }
    return dp[0][n-1];
}
```

### 678.有效的括号字符串

题干：

*给定一个只包含三种字符的字符串：`（ `，`）`和`\`，写一个函数来检验这个字符串是否能够组成合法括号组（其中* `*` *可以被视为（，）或空字符串）*

分析：

在原本没有 * 的情况下，在一个从左到右遍历该字符串的过程中，我们会有这样的判断：

- 如果该遍历点（出现的数量大于）的数量，那么可以期待后面出现）来抵消（
- 如果该遍历点）出现的数量大于（的数量，那么显然这个字符串已经不合法

由此，可以引入一个平衡值的概念，（增加该平衡值，）减少该平衡值，那么对于*，其对平衡值的影响是一段范围，那么就将平衡值设置为一段**范围[low,high]**，则平衡值的改变规则为：

- 遇到左括号：lo++, hi++
- 遇到星号：lo--, hi++（因为星号有三种情况）
- 遇到右括号：lo--, hi--

根据之前的合法判断分析，给出两个新的合法判断规则：

- 过程中不能出现 hi < 0，否则（存在无法匹配的右括号）不合法
- 结果不能出现 lo > 0，否则（有多余的左括号）不合法

```python
class Solution:
    def checkValidString(self, s: str) -> bool:
        lo=0
        hi=0
        for c in s:
            if c=='(':
                lo+=1
                hi+=1
            elif c=='*':
                if lo>0:lo-=1
                hi+=1
            else:
                if lo>0:lo-=1
                hi-=1
            if hi<0:
                return False
        return lo==0
```



### LRU 实现算法

```java
public class LRUCache {
        // 一个 HashMap 作为实际键值存储
        private HashMap<Integer, Integer> cacheMap = new HashMap<>();
        // 一个双端队列作为 lru 队列，保存的内容是按访问频度排序的 key
        private LinkedList<Integer> recentlyList = new LinkedList<>();
        private int capacity;

        public LRUCache(int capacity) {
            this.capacity = capacity;
        }

        public int get(int key) {
            if (!cacheMap.containsKey(key)) {
                return -1;
            }
            // 从双端lru队列移除所访问的 key，然后再加入，使得其位于队列最新位置
            recentlyList.remove((Integer) key);
            recentlyList.add(key);
            return cacheMap.get(key);
        }

        public void put(int key, int value) {
            if (cacheMap.containsKey(key)) {
                // 和 get 类似，如果包含key，先将访问到的元素移出
                recentlyList.remove((Integer) key);
            } else if (cacheMap.size() == capacity) {
                // 如果 put 了新值同时 cache 又满了
                // 从双端lru队列移除最末尾的 key ，并且还要根据这个 key 去向存储中移除指定存储
                cacheMap.remove(recentlyList.removeFirst());
            }
            // 将移出的访问元素再加入lru队列
            // 向存储中放入给定的键值
            recentlyList.add(key);
            cacheMap.put(key, value);
        }
    }
```

### 第k大个数

```java
// 用快排的方式寻找第K大个数

public class FindKthNumber {
    public int findKthLargest(int[] nums, int k) {
        return sort(nums, 0, nums.length-1, k);
    }
    private int sort (int[] nums,int l, int r, int k) {
        // 每次分割标准从 nums[l] 开始
        int base = nums[l];
        int left = l;
        int right = r;
        while (left < right) {
            // 从右出发遍历到第一个不满足大于 base 的值
            while (left < right && nums[right] > base) {
                right--;
            }
            // 和left指针交换，同时left前进一位，从left开始找
            if (left < right) {
                swap(nums,left,right);
                left++;
            }
            while (left < right && nums[left] < base) {
                left++;
            }
            if (left < right) {
                swap(nums,left,right);
                right--;
            }
        }
        // 排序完成之后 left/right 刚好是第 rank 大个数
        int rank = nums.length - left;
        // 如果满足直接返回，不满足则根据 k 和 rank 大小关系选择前序列或后序列
        if (rank == k) {
            return nums[left];
        } else if (rank < k) {
            return sort(nums, l, left - 1, k);
        } else {
            return sort(nums, left, right, k);
        }
    }

    private void swap(int[] nums,int left,int right) {
        int temp = nums[left];
        nums[left] = nums[right];
        nums[right] = temp;
    }
}
```
