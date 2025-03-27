using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class ShellController : MonoBehaviour
{
    public bool UpdateVariables = true;
    public bool GlobalShellDirection = true;

    [Header("Shell Components")]
    public Shader shellShader;
    public Texture2D shellTexture;
    public Texture2D shellsLocationTexture;
    public Color tint;

    [Header("Shell Variables")]
    [Range(0, 128)]
    public int shellCount = 16;
    [Range(1.0f, 1000.0f)]
    public float density = 100.0f;
    [Range(0.0f, 3.0f)]
    public float maxFurLenght = 2.0f;

    public Vector3 shellDirection;

    private Material shellMaterial;
    private List<GameObject> shells;

    private void OnEnable()
    {
        shellMaterial = new Material(shellShader);

        shells = new List<GameObject>();

        GameObject shellHolder = new GameObject("Shell Holder");
        shellHolder.transform.SetParent(this.transform, false);

        for (int i = 0; i < shellCount; i++)
        {
            shells.Add(new GameObject("Shell " + i.ToString()));
            shells[i].AddComponent<MeshFilter>();
            shells[i].AddComponent<MeshRenderer>();

            shells[i].GetComponent<MeshFilter>().mesh = this.GetComponent<MeshFilter>().mesh;
            shells[i].GetComponent<MeshRenderer>().material = shellMaterial;
            shells[i].transform.SetParent(shellHolder.transform, false);

            UpdateShaderVariables(i);
        }
    }

    private void FixedUpdate()
    {
        if (UpdateVariables)
        {
            for (int i = 0; i < shellCount; i++)
            {
                UpdateShaderVariables(i);
            }
        }
    }

    void UpdateShaderVariables(int _index)
    {

        SetKeyword(_index, "_GLOBAL_SHELL_DIRECTION", GlobalShellDirection);

        if(shellTexture)
        {
            shells[_index].GetComponent<MeshRenderer>().material.SetTexture("_ShellTexture", shellTexture);
        }
        else
        {
            shells[_index].GetComponent<MeshRenderer>().material.SetTexture("_ShellTexture", Texture2D.whiteTexture);
        }
        if (shellsLocationTexture)
        {
            shells[_index].GetComponent<MeshRenderer>().material.SetTexture("_ShellsLocationTexture", shellsLocationTexture);
        }
        else
        {
            shells[_index].GetComponent<MeshRenderer>().material.SetTexture("_ShellsLocationTexture", Texture2D.whiteTexture);
        }
        shells[_index].GetComponent<MeshRenderer>().material.SetColor("_Tint", tint);

        shells[_index].GetComponent<MeshRenderer>().material.SetInt("_ShellIndex", _index);
        shells[_index].GetComponent<MeshRenderer>().material.SetInt("_ShellCount", shellCount);
        shells[_index].GetComponent<MeshRenderer>().material.SetFloat("_Density", density);
        shells[_index].GetComponent<MeshRenderer>().material.SetFloat("_MaxFurLength", maxFurLenght);

        shells[_index].GetComponent<MeshRenderer>().material.SetVector("_ShellDirection", shellDirection);
    }
    void SetKeyword(int _index, string _keyword, bool _state)
    {
        if (_state)
        {
            shells[_index].GetComponent<MeshRenderer>().material.EnableKeyword(_keyword);
        }
        else
        {
            shells[_index].GetComponent<MeshRenderer>().material.DisableKeyword(_keyword);
        }
    }

    void OnDisable()
    {
        for (int i = 0; i < shells.Count; ++i)
        {
            Destroy(shells[i]);
        }
        shells.Clear();
    }
}

