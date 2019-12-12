Imports System
Imports Microsoft.VisualBasic

Structure OrbitInfo
    Public satellites As List(Of String)
    Public parent As String
End Structure
Module Program
    Function CountAllOrbits(ByRef orbitDict As Dictionary(Of String, OrbitInfo),
                            ByVal key As String,
                            ByVal depth As Integer) As Integer
        Dim result As Integer
        If Not orbitDict.ContainsKey(key) Then Return 0
        For Each satellite As String In orbitDict(key).satellites
            result += depth + CountAllOrbits(orbitDict, satellite, depth + 1)
        Next
        Return result
    End Function
    Function CountStepsTo(ByRef orbitDict As Dictionary(Of String, OrbitInfo),
                            ByVal start_object As String,
                            ByVal end_object As String,
                            ByVal prev_object As String) As Integer
        If start_object = end_object Then Return 0
        Dim result As Integer
        If orbitDict(start_object).parent IsNot Nothing Then
            If orbitDict(start_object).parent <> prev_object Then
                result = CountStepsTo(orbitDict, orbitDict(start_object).parent, end_object, start_object)
                If result <> -1 Then
                    Return result + 1
                End If
            End If
        End If

        For Each satellite As String In orbitDict(start_object).satellites
            If satellite <> prev_object Then
                result = CountStepsTo(orbitDict, satellite, end_object, start_object)
                If result <> -1 Then
                    Return result + 1
                End If
            End If
        Next
        Return -1

    End Function
    Sub Main(args As String())
        Dim orbits As String()
        orbits = System.IO.File.ReadAllLines("Day 6.txt")

        Dim orbitDict As New Dictionary(Of String, OrbitInfo)
        For Each orbit As String In orbits
            Dim bigger, smaller As String
            Dim split_orbit As String()
            split_orbit = orbit.Split(")")
            bigger = split_orbit(0)
            smaller = split_orbit(1)
            If Not orbitDict.ContainsKey(bigger) Then
                orbitDict(bigger) = New OrbitInfo With {.satellites = New List(Of String)}
            End If
            If Not orbitDict.ContainsKey(smaller) Then
                orbitDict(smaller) = New OrbitInfo With {.satellites = New List(Of String), .parent = bigger}
            End If
            orbitDict(bigger).satellites.Add(smaller)
            Dim temp = orbitDict(smaller)
            temp.parent = bigger
            orbitDict(smaller) = temp
        Next
        Console.WriteLine(CountAllOrbits(orbitDict, "COM", 1))
        Console.WriteLine(CountStepsTo(orbitDict, "YOU", "SAN", "YOU") - 2)

    End Sub
End Module
