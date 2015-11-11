
## Huffman Tables ##

Huffman Tables are pretty cool. It's a lossless compression technique where you build a tree based off the number of times something occurs. So let's take the phrase `Building a huffman table`. Each one of the characters in there is 8 bits or 1 byte. So that's 192 bits or 24 bytes in that phrase. That isn't a whole lot, but it can quickly get bigger as you continue to add more and more characters. However as you add more and more characters, you are bound to repeat some. Our goal here is to compress this into an easily traversable structure that puts the most common letters at the top and the least common at the bottom. When we finish encoding, the letters at the top will be represented by a lower number of bits than those at the bottom. If that doesn't make sense, or any of the the tables below don't make sense, just keep reading. Hopefully as you read, the puzzle will come together to form a clear picture. If not, feel free to shoot me an email!

So we want to compress these 24 bytes down to something much smaller. Let's break it down and build a little table showing how often each letter appears:

Table 1.
| NODE | WEIGHT |
| ------- | -------- |
| B        | 2            |
| U        | 2            |
| I         | 2            |
| L        | 2            |
| D        | 1            |
| N        | 2           |
| G        | 1           | 
| SPACE | 3          |
| A        | 3           |
| H        | 1           |
| F        | 2           |
| M       | 1           |
| T        | 1           |
| E        | 1           |
 
 Now we have the characters and we have the weight (the frequency that they appear in the phrase). So good, so far. Now we need to take the lowest two and combine them. Let's do this for D and G and then again for H and M and one last time for T and E. I started doing this in the table below.

Table 2.
| NODE | WEIGHT |
| ------- | -------- |
| B        | 2            |
| U        | 2            |
| I         | 2            |
| L        | 2            |
| N        | 2           |
| F        | 2           |
| (H & M) | 2           |
| (G & D) | 2          |
| (T & E) | 2           |
| SPACE | 3          |
| A        | 3           |

We now have three merged cells with the added weight of both their children. Let's continue to add the lowest weights.  

Table 3.
| NODE | WEIGHT |
| ------- | -------- |
| (B & U)   | 4            |
| (I & L)   | 4            |
| (N & F)    | 4           |
| ((H & M) & (G & D)) | 4           |
| (T & E) | 2           |
| SPACE | 3          |
| A        | 3           |


At this point, we have done all the easiest combinations. However now we have the lowest, a weight of 2, and then the second lowest with a weight of 3. This is one of the most important steps in building our tree/table. We need to make sure that the largest goes on the left and the smallest goes on the right. This is to make sure that traversal is possible, which we will discuss later. In the table below, I am going to continue to combine the nodes.

Table 4.
| NODE | WEIGHT |
| ------- | -------- |
| ((B & U) & A)   | 7            |
| ((N & F) & (I & L))   | 8            |
| ((H & M) & (G & D)) | 4           |
| (SPACE & (T & E)) | 5           |

And then we keep combining.  

Table 5.
| NODE | WEIGHT |
| ------- | -------- |
| (((N & F) & (I & L)) & ((B & U) & A))   | 15            |
| ((SPACE & (T & E)) & ((H & M) & (G & D))) | 9           |
    
And finallyw
  
Table 6. 
| NODE | WEIGHT |
| ------- | -------- |
| ((((N & F) & (I & L)) & ((B & U) & A)) & ((SPACE & (T & E)) & ((H & M) & (G & D)))) | 24          |

Now we have a full tree. What we have above is our "root node". Given this root node, you can build any word that contains any of these characters. The beauty of this is that it is also super efficient for storing the sentence we gave it at the start, since that's how we built the tree in the first place. So let's build the word 'BANG' from the root node.

The way you build any words from this is by going either left or right. To represent this, I will be using `L` for left, and `R` for right. I separated every 'chunk' with an ampersand. So the left side of the ampersand would be represented by an `L` and the right side represented by the `R`. Let's first take a look at table 2. In that one, we have 3 combined nodes at the very bottom of the table. To reference the letter `M` in the `H & M` combined node, it would simply be `R`, because `M` is on the right side of the ampersand. Now if we take this a step further and go to table 4, you see that we have nodes that are comprised of other nodes. This means we have to go a bit deeper. Now, to reference the M in the `(H & M) & (G & D)` node, we would first have to go `L` to get to the `H & M` node, and then go `R` to get to the M. 

So applying this concept to the root node, let's get the 'B' for our 'BANG'. First, we go `L` (right), which puts us in the `(((N & F) & (I & L)) & ((B & U) & A)` node. Now we go `R` to put us into the `(B & U) & A` node. We go `L` to put us into the `B & U` node, and then we go `L` again to get the `B`. 

When we put these instructions together, it gives us the path `LRRL` to get to `B`.  Now if we keep doing the other letters, we eventually end up with `(B) LRLL (A) LRR (N) LLLL (G) RRRL` but this alone isn't very good for compression. Right now, we are basically quadrupling the amount of data we would need to send. But what if we converted it to binary? At each ampersand, there are only two options. So let's represent the `L` as a `1`, and the `R` as a `0`. Using this, our `BANG` becomes `(B) 1011 (A) 100 (N) 1111 (G) 0001`. Since we can write one bit as a `0` or a `1`, we have no effectively halved the size of each of our characters from 8 bits (1 byte) to 3-4 bits (1/2 - 1/3 byte). 

Following this process, decoding is very similar. You start at the root node, and then go left if it's a 1, and right if it's a 0, until you end up at a character. Then you write down that character, and restart at the next digit.

In case you were wondering, the compressed form of `Building a huffman table` is `(B) 1011 (U) 1010 (I) 1101 (L) 1100 (D) 0000 (I) 1101 (N) 1111 (G) 0001 (SPACE) 011 (A) 100 (SPACE) 011 (H) 0011 (U) 1010 (F) 1110 (F) 1110 (M) 0010 (A) 100 (N) 1111 (SPACE) 011 (T) 0101 (A) 100 (B) 1011 (L) 1100 (E) 0100`

## Ruby Implementation ##

If you just wanted to learn how huffman tables work, then you can stop here. If you want to learn how to implement this in Ruby, keep reading. 

Hopefully by now we understand how a Huffman Table works. If not, you might want to (re)read the section above. Now the question is: How do we implement a Huffman Table in Ruby?

We're gonna need two classes: a a node class and a main class. Let's define them.

```
class Huffman
	def initialize()

	end
end

class HuffmanNode
	def initialize()
	
	end
end
```

Let's start by creating the very first table above. For this, we probably just want a hash map and then split the input up.

```
class Huffman
	def initialize()
		seeds = Hash.new(0)
		characters = gets.chomp
		characters.length.times { |pos|
			seeds[pos]+=1
		}
	end
end
```

Now we have the first set of nodes or the 'seeds'.  What we do above is create a Hash with the default value of 0 so that any character starts with 0, then we loop through each character in the input and increment that character's weight in the hash. This way even if this is the first time we have seen this character, it will still have a numeric value that we can increment. Now let's start to define our Huffman Node class.

```
class HuffmanNode
	def initialize(char, weight, leftChild, rightChild, parent)
		@char = char
		@weight = weight
		@leftChild = leftChild
		@rightChild = rightChild
		@parent = parent
	end

	def isLeaf()
        if (@rightChild == nil && @leftChild == nil)
            return true
        end
        return false
    end

    def isBranch()
        if (@rightChild != nil || @leftChild != nil)
            return true
        end
        return false
    end

    def getChar()
        return @char
    end

    def getWeight()
        return @weight
    end

    def getLeftChild()
        return @leftChild
    end

    def getRightChild()
        return @rightChild
    end

	def setParent(parent)
		@parent = parent
	end
	
    def getParent()
        return @parent
    end
end
```

In the above code, we have defined what the Huffman Node requires, getters for everything and a setter for the parent. This may seem like a lot of un-necessary stuff, especially for the first layer of nodes where there won't be children or parents. It is for this reason that we have also defined a way to check if this particular instance of the node is a "leaf" or a "branch", the `isLeaf` and `isBranch` methods. When we create our first batch of the Huffman Nodes which are just the letters and their weights (leafs), we are going to assume that the parent, the leftChild, and the rightChild will be null, but the char and the weight will be set. From then on, for nodes that are a combination of two nodes (branches), we will assume that the char is null and everything else is set.

You may also wonder why we have a setter for only parent and nothing else. The reason for this is that when we are creating a new instance,  we will have no way of knowing what the parent is. Instead, we will set the parent later on once we know what the parent will be. So we make a setter!

Now let's return to the Huffman class and start generating some nodes.

```
class Huffman
	def initialize()

		@birchTree = Array.new()
		@pineTree = Array.new()

		seeds = Hash.new(0)
		characters = gets.chomp
		characters.length.times { |pos|
			seeds[pos]+=1
		}
		seed = seed.sort_by { |key,value| value }.to_h
		seed.each { |key,value|
			@birchTree << HuffmanNode.new(value, key, nil, nil, nil)
		}
		while(@birchTree.size > 0 || @pineTree.size > 1)
			leftNode = lowest(@birchTree, @pineTree)
            rightNode = lowest(@birchTree, @pineTree)
            node = HuffmanNode.new(leftNode.getWeight + rightNode.getWeight, nil, leftNode, rightNode, nil)
            node.getLeftChild.setParent(node)
            node.getRightChild.setParent(node)
	        @pineTree.push(node)
		end
		@rootNode = @pineTree[0]
	end

    def lowest(arr1, arr2)
        if (arr1.length == 0)
            return arr2.delete_at(0)
        elsif (arr2.length == 0)
            return arr1.delete_at(0)
        elsif (arr1[0].getWeight < arr2[0].getWeight)
            return arr1.delete_at(0)
        end
        return arr2.delete_at(0)
    end

end
```

What we need to do is take the two lowest weights, create a new Huffman Node with the weight being the sum of the two nodes' weights, and the left child being the biggest and the smallest child being the biggest. Then after we create this Huffman Node instance, we set the left and right children's parent to be this new combined node instance. Then we have to remove the left and right children from the list, and add this new node to the list. 

We start doing this by creating two new arrays. For lack of better names, I named them `birchTree` and `pineTree`. We need two so that we can do more efficient sorting. It might seem like the most obvious way to sort would be to make one array or hash and sort by the weight, but calling the sort function every single time you loop through can get much more memory intensive than necessary. So instead, we can write our own little `lowest` function which takes two arrays as input. Our `birchTree` will start off with all our seeds and end empty, and our `pineTree` will start empty and end with our root node. Our `lowest` function will need to first check if our first array is empty. If it is, it returns the second array's first item, and then it will delete it. If the second array is empty, then it returns the first array's first item, and the deletes it. If neither of their lengths are 0, then it checks if the first item in the first array's weight is less than the second array's first item's weight. If that's true, then it returns the first array's first item, then deletes it. Finally, if none of those are true, then it returns the second array's first item, and then deletes it. 

Now, while the `birchTree` array is bigger than zero, or the `pineTree` array is bigger than 1,  we run our `lowest` function twice and save the output each time. This saves a temporary instance of the two lowest nodes & deletes them from the arrays, killing two birds with one stone. Then we create a new instance of the Huffman Node class with the sum of the two temporary instance weights, the left and right children, and set the parent of the children to this new node. Since we do this until the `pineTree` array is 1 and the `birchTree` array is 0 and delete the nodes from the arrays as we use them, it will only finish when we have one node left in the pineTree array which will be our root node. Tah-dah!

We've finished most of the tree generation. Now we have a root node that contains all of our sub-nodes, and we can get to any point in the tree by getting the left or right children. But we want to start doing the actual compression. It's great we have this tree, but it doesn't mean much if we don't have an actual message to send or a way to transport the tree. Let's tackle the transporting of the tree first, then we will do the final compression.

The obvious solution is to serialize the tree object. From Wikipedia, *"In computer science, in the context of data storage, serialization is the process of translating data structures or object state into a format that can be stored (for example, in a file or memory buffer, or transmitted across a network connection link) and reconstructed later in the same or another computer environment..."*. Basically, it will let us store that exact instance of the root huffman node so that we can share this with whatever computers will be decompressing the message. 

Let's do this in our Huffman class:

```
class Huffman
	def initialize()

		@birchTree = Array.new()
		@pineTree = Array.new()

		seeds = Hash.new(0)
		characters = gets.chomp
		characters.length.times { |pos|
			seeds[pos]+=1
		}
		seed = seed.sort_by { |key,value| value }.to_h
		seed.each { |key,value|
			@birchTree << HuffmanNode.new(value, key, nil, nil, nil)
		}
		while(@birchTree.size > 0 || @pineTree.size > 1)
			leftNode = lowest(@birchTree, @pineTree)
            rightNode = lowest(@birchTree, @pineTree)
            node = HuffmanNode.new(leftNode.getWeight + rightNode.getWeight, nil, leftNode, rightNode, nil)
            node.getLeftChild.setParent(node)
            node.getRightChild.setParent(node)
	        @pineTree.push(node)
		end
		@rootNode = @pineTree[0]
		
		File.open(File.expand_path("~/huffmanKey"), 'w+' ) { |file|
			file.write(Marshal.dump(@rootNode))
		}

	end
end
```

That's it. It's a swift little solution, but the file it makes is compact and it's easy to load and use again as long as you already have the Huffman Node class. If you don't, it isn't loadable. 

That was the easy part. Now we get to do the hard part. We have to find a way to write only bits to a file and a way to generate the path. Let's first tackle a way to generate a path of just 1's and 0's. Let's first take a look at the Huffman Node class. Having the path generation in the Huffman Node class ensures that all its instances will be able to generate a part of the path:

```
class HuffmanNode
	def initialize(char, weight, leftChild, rightChild, parent)
		@char = char
		@weight = weight
		@leftChild = leftChild
		@rightChild = rightChild
		@parent = parent
	end
	
    def makePath(hash, currPath)
        if (isLeaf)
            hash[@char] = currPath
        else
            @leftChild.makePath(hash, currPath + '0')
            @rightChild.makePath(hash, currPath + '1')
        end
    end

	def isLeaf()
        if (@rightChild == nil && @leftChild == nil)
            return true
        end
        return false
    end

    def isBranch()
        if (@rightChild != nil || @leftChild != nil)
            return true
        end
        return false
    end

    def getChar()
        return @char
    end

    def getWeight()
        return @weight
    end

    def getLeftChild()
        return @leftChild
    end

    def getRightChild()
        return @rightChild
    end

	def setParent(parent)
		@parent = parent
	end
	
    def getParent()
        return @parent
    end
end
```

We have a makePath function now, which takes in a hash and string. By default, hashes are mutable, so we can pass our makePath function one hash, and it will be able to modify and set values in this hash. This checks if this current instance is a leaf. If it isn't, then it adds a `1` or a `0` and then continues down the left child or right child respectively. If it is a character, then it adds a new hash value with the key being the character that path represents, and the value being the actual path. This way, if I access the hash at the `a` character for example, it would give me a binary representation of the path to get there in the tree.

Now we have a function to make the path. Let's implement it:

```
class Huffman
	def initialize()

		@birchTree = Array.new()
		@pineTree = Array.new()
		@roots = Hash.new()

		seeds = Hash.new(0)
		characters = gets.chomp
		characters.length.times { |pos|
			seeds[pos]+=1
		}
		seed = seed.sort_by { |key,value| value }.to_h
		seed.each { |key,value|
			@birchTree << HuffmanNode.new(value, key, nil, nil, nil)
		}
		while(@birchTree.size > 0 || @pineTree.size > 1)
			leftNode = lowest(@birchTree, @pineTree)
            rightNode = lowest(@birchTree, @pineTree)
            node = HuffmanNode.new(leftNode.getWeight + rightNode.getWeight, nil, leftNode, rightNode, nil)
            node.getLeftChild.setParent(node)
            node.getRightChild.setParent(node)
	        @pineTree.push(node)
		end
		@rootNode = @pineTree[0]
		
		File.open(File.expand_path("~/huffmanKey"), 'w+' ) { |file|
			file.write(Marshal.dump(@rootNode))
		}

		@rootNode.makePath(@roots, "")
		ouput = Array.new()
		characters.length.times { |x|
			output << @@roots[characters[x]]
		}
		temp = output.join

	end
end
```

First, we create the hash that we are going to use in the makePath function, and we also create an array for our output from the path. For continuity in our metaphor, I named it `roots` and for the output, `output`. Once we run the makePath on the `roots` hash, it will have all of the characters and their corresponding paths. From this, we can actually build the string of 0's and 1's. We do this in the code above by looping through our original input again. This time, we get the path of each character in order and append it to the output array. Then we save the final string to temp by using the `join` function on the `output` array, which converts an array to a string. 

Sorry, it's not time for celebrating yet. We now have two problems in front of us. The first is pretty straight forward, and not too hard to fix. Right now, we have the output as a string, with each character being 8 bytes, even though they are 0's and 1's. We want these to be in bits, where it is a 1to1 ratio between our 0's and 1's and the number of bits. To fix this, Ruby has a really nifty function for arrays called the `pack` function. This packs the array down into a specified format. It can do lots of different formats including hexadecimal and binary. For our purpose, we want binary. Since this is also our message, we want to be able to write it to a file that we can send, so let's implement that:

```
class Huffman
	def initialize()

		@birchTree = Array.new()
		@pineTree = Array.new()
		@roots = Hash.new()

		seeds = Hash.new(0)
		characters = gets.chomp
		characters.length.times { |pos|
			seeds[pos]+=1
		}
		seed = seed.sort_by { |key,value| value }.to_h
		seed.each { |key,value|
			@birchTree << HuffmanNode.new(value, key, nil, nil, nil)
		}
		while(@birchTree.size > 0 || @pineTree.size > 1)
			leftNode = lowest(@birchTree, @pineTree)
            rightNode = lowest(@birchTree, @pineTree)
            node = HuffmanNode.new(leftNode.getWeight + rightNode.getWeight, nil, leftNode, rightNode, nil)
            node.getLeftChild.setParent(node)
            node.getRightChild.setParent(node)
	        @pineTree.push(node)
		end
		@rootNode = @pineTree[0]
		
		File.open(File.expand_path("~/huffmanKey"), 'w+' ) { |file|
			file.write(Marshal.dump(@rootNode))
		}

		@rootNode.makePath(@roots, "")
		ouput = Array.new()
		characters.length.times { |x|
			output << @@roots[characters[x]]
		}
		temp = output.join

		File.open(File.expand_path("~/huffmanKey"), 'wb' ) { |file|
            file.write([temp].pack("B*"))
        }

	end
end
```

This solves our first problem. It opens a file with write (w) and bit (b) modes to ensure that we don't have unwanted data in our file. Then it writes to the file using the pack method with binary (B) mode. So far so good! Now enters the second problem: what if our data isn't perfectly divisible by 8? In order for file.write to write properly, it must be divisible by 8. If the data isn't, it adds padding to the end, which we don't want. The solution is to include 3 bits at the beginning that tell us exactly where in the last byte our data ends, and then to fill the rest up with zero. This way, when we are decoding, we read the first three bits, then we read from the fourth bit until the length of the input minus the total of the first 3 bits. 

```
class Huffman
	def initialize()

		@birchTree = Array.new()
		@pineTree = Array.new()
		@roots = Hash.new()

		seeds = Hash.new(0)
		characters = gets.chomp
		characters.length.times { |pos|
			seeds[pos]+=1
		}
		seed = seed.sort_by { |key,value| value }.to_h
		seed.each { |key,value|
			@birchTree << HuffmanNode.new(value, key, nil, nil, nil)
		}
		while(@birchTree.size > 0 || @pineTree.size > 1)
			leftNode = lowest(@birchTree, @pineTree)
            rightNode = lowest(@birchTree, @pineTree)
            node = HuffmanNode.new(leftNode.getWeight + rightNode.getWeight, nil, leftNode, rightNode, nil)
            node.getLeftChild.setParent(node)
            node.getRightChild.setParent(node)
	        @pineTree.push(node)
		end
		@rootNode = @pineTree[0]
		
		File.open(File.expand_path("~/huffmanKey"), 'w+' ) { |file|
			file.write(Marshal.dump(@rootNode))
		}

		@rootNode.makePath(@roots, "")
		ouput = Array.new()
		characters.length.times { |x|
			output << @@roots[characters[x]]
		}
		temp = output.join
        needsNumb = 8 - ((temp.length + 3) % 8)
        differentTemp = needsNumb.to_s(2)
        if (differentTemp.length < 3)
            (3 - differentTemp.length).times { |x|
                differentTemp = "0" + differentTemp
            }
        end
        needsNumb.times { |x|
            temp = temp + "0"
        }
        temp = differentTemp+temp

		File.open(File.expand_path("~/huffmanKey"), 'wb' ) { |file|
            file.write([temp].pack("B*"))
        }

	end
end
```

And that's it. Now you have successfully written or (I hope) understand how to write a Ruby huffman table encoder. The decoding is very simple, so I have omitted that from this post and included it along with a prettied up version of the rest of this in a GitHub repo. 

---

I really hope you enjoyed this and, most importantly, learned something from it. Feel free to shoot me an email with any questions. It's [howard@getcoffee.io](mailto:howard@getcoffee.io). Until next time!