#!/usr/bin/ruby

class Huffman
    def initialize()
        while true
            print "Are you (E)ncoding or (D)ecoding: "
            input = gets.chomp
            case
            when input.match(/\AE.*/i)
                print "What is your message: "
                message = gets.chomp
                keyPath = ""
                messagePath = ""
                while true
                    print "Where do you want to store the message: "
                    messagePath = gets.chomp
                    shouldExpand = messagePath.include? "~"
                    if(shouldExpand)
                        messagePath = File.expand_path(messagePath)
                    end
                    if (File.exists? messagePath)
                         break
                    end
                    puts "Yikes! That isn't a valid directory."
                end
                while true
                    print "Where do you want to store the key: "
                    keyPath = gets.chomp
                    shouldExpand = keyPath.include? "~"
                    if(shouldExpand)
                        keyPath = File.expand_path(keyPath)
                    end
                    if (File.exists? keyPath)
                         break
                    end
                    puts "Holly backfire, Batman! That directory doesn't exist."
                end
                growTree(message, keyPath, messagePath)
                break
            when input.match(/\AD.*/i)
                messagePath = ""
                keyPath = ""
                while true
                    print "Where is the message located: "
                    messagePath = gets.chomp
                    shouldExpand = messagePath.include? "~"
                    if(shouldExpand)
                        messagePath = File.expand_path(messagePath)
                    end
                    if (File.exists? messagePath)
                         break
                    end
                    puts "Uh-oh! That file doesn't exist."
                end
                while true
                    print "Where is the key located: "
                    keyPath = gets.chomp
                    shouldExpand = keyPath.include? "~"
                    if(shouldExpand)
                        keyPath = File.expand_path(keyPath)
                    end
                    if (File.exists? keyPath)
                         break
                    end
                    puts "Yowza! That file doesn't exist."
                end
                digTree(keyPath, messagePath)
                break
            else
                puts "Oops! Looks like that command isn't valid."
            end
        end
    end

    def digTree(key, message)
        received = Marshal.load(File.read(key))
        source = File.binread(message)
        bits = source.unpack("B*")[0]
        rem = bits[0..2]
        rem = rem.to_i(2)
        almostThere = bits[3...(bits.length - rem)]
        tempNode = received
        almostThere.length.times { |x|
            thisBit=almostThere[x]
            if(thisBit=="1")
                tempNode=tempNode.getRightChild
            else
                tempNode=tempNode.getLeftChild
            end
            if(tempNode.isLeif)
                print tempNode.getChar
                tempNode=received
            end
        }
        print "\n"
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

    def growTree(message, keyPath, messagePath)

        @node = Array.new()
        @tree = Array.new()
        @roots = Hash.new()

        seed = Hash.new(0)
        message.length.times { |x|
            seed[message[x]] +=  1
        }
        seed = seed.sort_by { |key,value| value }.to_h
        seed.each { |key,value|
            @tree << HuffmanNode.new(value, key, nil, nil, nil)
        }
        while(@tree.size > 0 || @node.size > 1)
            leftNode = lowest(@tree, @node)
            rightNode = lowest(@tree, @node)
            node = HuffmanNode.new(leftNode.getWeight + rightNode.getWeight, nil, leftNode, rightNode, nil)
            node.getLeftChild.setParent(node)
            node.getRightChild.setParent(node)
            @node.push(node)
        end
        rootNode = @node[0]
        rootNode.growHash(@roots,"")
        output = Array.new()
        message.length.times { |x|
            output << @roots[message[x]]
        }
        temp = output.join
        puts temp
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

        File.open(keyPath + "/huffmanKey", 'a+' ) { |file|
            file.write(Marshal.dump(rootNode))
        }

        File.open(messagePath + "/huffmanMsg", 'wb' ) { |file|
            file.write([temp].pack("B*"))
        }
    end
end

class HuffmanNode

    def initialize(weight, char, leftChild, rightChild, parent)
        @weight = weight
        @char = char
        @leftChild = leftChild
        @rightChild = rightChild
        @parent = parent
    end

    def growHash(hash, currPath)
        if (isLeif)
            hash[@char] = currPath
        else
            @leftChild.growHash(hash, currPath + '0')
            @rightChild.growHash(hash, currPath + '1')
        end
    end

    def isLeif()
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

Huffman.new
